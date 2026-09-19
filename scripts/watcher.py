#!/usr/bin/env python3
"""
Background file watcher using Linux native inotify.
Watches the repository for:
- New week and problem directories (auto-generates problem README.md)
- Creation, modification, deletion, or renaming of Main.java, input.txt, and directories
- Automatically updates root README.md tracker
"""

import os
import sys
import time
import select
import struct
import signal
import ctypes

# Import helper functions from update_tracker.py
from update_tracker import (
    get_repo_root,
    scan_repository,
    update_root_readme,
    ensure_problem_readme,
)

# Inotify constants from Linux kernel
IN_NONBLOCK = 0x00000800
IN_CLOEXEC = 0x00080000

IN_MODIFY = 0x00000002
IN_CLOSE_WRITE = 0x00000008
IN_MOVED_FROM = 0x00000040
IN_MOVED_TO = 0x00000080
IN_CREATE = 0x00000100
IN_DELETE = 0x00000200
IN_DELETE_SELF = 0x00000400
IN_IGNORED = 0x00008000
IN_ISDIR = 0x40000000

WATCH_MASK = (
    IN_CREATE
    | IN_DELETE
    | IN_MODIFY
    | IN_CLOSE_WRITE
    | IN_MOVED_FROM
    | IN_MOVED_TO
    | IN_DELETE_SELF
)

EVENT_HEADER_FORMAT = "iIII"
EVENT_HEADER_SIZE = struct.calcsize(EVENT_HEADER_FORMAT)


class InotifyWatcher:
    def __init__(self, repo_root):
        self.repo_root = os.path.abspath(repo_root)
        self.libc = ctypes.CDLL("libc.so.6", use_errno=True)

        self._init_inotify = self.libc.inotify_init1
        self._init_inotify.restype = ctypes.c_int
        self._init_inotify.argtypes = [ctypes.c_int]

        self._add_watch = self.libc.inotify_add_watch
        self._add_watch.restype = ctypes.c_int
        self._add_watch.argtypes = [ctypes.c_int, ctypes.c_char_p, ctypes.c_uint32]

        self._rm_watch = self.libc.inotify_rm_watch
        self._rm_watch.restype = ctypes.c_int
        self._rm_watch.argtypes = [ctypes.c_int, ctypes.c_int]

        self.fd = self._init_inotify(IN_NONBLOCK | IN_CLOEXEC)
        if self.fd < 0:
            errno = ctypes.get_errno()
            raise OSError(errno, f"Failed to initialize inotify: {os.strerror(errno)}")

        self.wd_to_path = {}
        self.path_to_wd = {}
        self.running = True

    def add_watch(self, path):
        path = os.path.abspath(path)
        if path in self.path_to_wd:
            return self.path_to_wd[path]

        wd = self._add_watch(self.fd, path.encode("utf-8"), WATCH_MASK)
        if wd >= 0:
            self.wd_to_path[wd] = path
            self.path_to_wd[path] = wd
            return wd
        return None

    def remove_watch_by_wd(self, wd):
        path = self.wd_to_path.pop(wd, None)
        if path:
            self.path_to_wd.pop(path, None)
            self._rm_watch(self.fd, wd)

    def is_watched_dir(self, path):
        rel = os.path.relpath(path, self.repo_root)
        if rel == ".":
            return True
        parts = rel.split(os.sep)
        if any(p.startswith(".") for p in parts):
            return False
        if len(parts) == 1 and parts[0].startswith("week-"):
            return True
        if len(parts) == 2 and parts[0].startswith("week-") and parts[1].startswith("problem-"):
            return True
        return False

    def register_all_dirs(self):
        # Watch root
        self.add_watch(self.repo_root)
        for root, dirs, _ in os.walk(self.repo_root):
            # Exclude hidden directories like .git
            dirs[:] = [d for d in dirs if not d.startswith(".")]
            for d in dirs:
                full_dir = os.path.join(root, d)
                if self.is_watched_dir(full_dir):
                    self.add_watch(full_dir)

    def close(self):
        self.running = False
        try:
            os.close(self.fd)
        except OSError:
            pass

    def run(self):
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Watcher started on {self.repo_root}")
        self.register_all_dirs()

        # Initial sync
        stats = scan_repository(self.repo_root)
        update_root_readme(self.repo_root, stats)

        poll = select.poll()
        poll.register(self.fd, select.POLLIN)

        pending_update = False
        last_event_time = 0.0
        DEBOUNCE_DELAY = 0.3  # seconds

        while self.running:
            # If an update is pending and debounce delay has passed, perform the update
            now = time.time()
            if pending_update and (now - last_event_time >= DEBOUNCE_DELAY):
                print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Triggering repository scan and tracker update...")
                stats = scan_repository(self.repo_root)
                update_root_readme(self.repo_root, stats)
                pending_update = False

            # Wait up to 200ms for inotify events
            events = poll.poll(200)
            if not events:
                continue

            for fd, event in events:
                if fd != self.fd:
                    continue
                try:
                    data = os.read(self.fd, 16384)
                except BlockingIOError:
                    continue
                except OSError as e:
                    if not self.running:
                        break
                    print(f"Error reading inotify fd: {e}", file=sys.stderr)
                    continue

                offset = 0
                while offset < len(data):
                    wd, mask, cookie, length = struct.unpack_from(
                        EVENT_HEADER_FORMAT, data, offset
                    )
                    offset += EVENT_HEADER_SIZE
                    name = ""
                    if length > 0:
                        raw_name = data[offset : offset + length]
                        name = raw_name.rstrip(b"\x00").decode("utf-8", errors="replace")
                        offset += length

                    if mask & IN_IGNORED:
                        self.remove_watch_by_wd(wd)
                        continue

                    dir_path = self.wd_to_path.get(wd)
                    if not dir_path:
                        continue

                    # Ignore changes to root README.md to prevent loops
                    if dir_path == self.repo_root and name == "README.md":
                        continue

                    # Ignore hidden files / logs / class files
                    if name.startswith(".") or name.endswith(".class") or name.endswith(".log"):
                        continue

                    full_path = os.path.join(dir_path, name) if name else dir_path

                    # Check if a directory was created or moved in
                    if mask & (IN_CREATE | IN_MOVED_TO):
                        if os.path.isdir(full_path) and self.is_watched_dir(full_path):
                            self.add_watch(full_path)
                            rel = os.path.relpath(full_path, self.repo_root)
                            parts = rel.split(os.sep)
                            if len(parts) == 1 and parts[0].startswith("week-"):
                                # If a week directory was created, inspect any problem subdirectories inside it
                                try:
                                    for sub in os.listdir(full_path):
                                        sub_full = os.path.join(full_path, sub)
                                        if os.path.isdir(sub_full) and sub.startswith("problem-"):
                                            self.add_watch(sub_full)
                                            ensure_problem_readme(sub_full)
                                except OSError:
                                    pass
                            elif len(parts) == 2 and parts[0].startswith("week-") and parts[1].startswith("problem-"):
                                ensure_problem_readme(full_path)

                    # Mark pending update
                    pending_update = True
                    last_event_time = time.time()


def main():
    repo_root = get_repo_root()
    watcher = InotifyWatcher(repo_root)

    def handle_signal(sig, frame):
        print("\nStopping watcher...")
        watcher.close()
        sys.exit(0)

    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)

    try:
        watcher.run()
    except KeyboardInterrupt:
        pass
    finally:
        watcher.close()


if __name__ == "__main__":
    main()
