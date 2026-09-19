#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PID_FILE="$REPO_ROOT/.watcher.pid"
LOG_FILE="$REPO_ROOT/.watcher.log"

is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid="$(cat "$PID_FILE" 2>/dev/null || true)"
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

case "${1:-status}" in
    start)
        if is_running; then
            echo "Watcher is already running (PID: $(cat "$PID_FILE"))."
            exit 0
        fi
        echo "Starting watcher in background..."
        nohup python3 -u "$SCRIPT_DIR/watcher.py" < /dev/null >> "$LOG_FILE" 2>&1 &
        pid=$!
        disown "$pid" 2>/dev/null || true
        echo "$pid" > "$PID_FILE"
        sleep 0.5
        if is_running; then
            echo "Watcher started successfully (PID: $(cat "$PID_FILE"))."
            echo "Logs: $LOG_FILE"
        else
            echo "Failed to start watcher. Check logs: $LOG_FILE" >&2
            exit 1
        fi
        ;;

    stop)
        if is_running; then
            pid="$(cat "$PID_FILE")"
            echo "Stopping watcher (PID: $pid)..."
            kill "$pid" 2>/dev/null || true
            rm -f "$PID_FILE"
            echo "Watcher stopped."
        else
            echo "Watcher is not running."
            rm -f "$PID_FILE"
        fi
        ;;

    status)
        if is_running; then
            echo "Watcher is running (PID: $(cat "$PID_FILE"))."
        else
            echo "Watcher is NOT running."
        fi
        ;;

    run)
        echo "Running watcher in foreground (Ctrl+C to stop)..."
        exec python3 "$SCRIPT_DIR/watcher.py"
        ;;

    *)
        echo "Usage: $0 {start|stop|status|run}"
        exit 1
        ;;
esac
