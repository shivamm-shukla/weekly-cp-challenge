#!/usr/bin/env python3
"""
Scans the repository for week and problem folders, generates boilerplate
README.md files for new problem folders if missing, and updates the Progress
Tracker table in root README.md.
"""

import os
import re
import sys

BOILERPLATE_README = """# Problem Title

- **Platform:** [e.g. LeetCode / Codeforces / AtCoder]
- **Problem URL:** [Link]

## Problem Summary
<!-- Add a brief summary of the problem statement here. Do not copy copyrighted text. -->

## Approach
<!-- Explain your intuition and thought process. -->

## Algorithm
<!-- Step-by-step description of the algorithm. -->

## Complexity
- **Time Complexity:** O(...)
- **Space Complexity:** O(...)

## Notes
<!-- Edge cases, pitfalls, or alternative ideas. -->
"""

TRACKER_START_MARKER = "<!-- AUTO-TRACKER:START -->"
TRACKER_END_MARKER = "<!-- AUTO-TRACKER:END -->"


def natural_sort_key(s):
    """Sort strings containing numbers in natural human order (e.g. week-1, week-2, week-10)."""
    return [int(text) if text.isdigit() else text.lower() for text in re.split(r"(\d+)", s)]


def get_repo_root():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.abspath(os.path.join(current_dir, ".."))
    if os.path.isdir(os.path.join(parent_dir, ".git")):
        return parent_dir
    return os.getcwd()


def ensure_problem_readme(problem_dir):
    readme_path = os.path.join(problem_dir, "README.md")
    if not os.path.exists(readme_path):
        try:
            with open(readme_path, "w", encoding="utf-8") as f:
                f.write(BOILERPLATE_README)
            print(f"Created boilerplate README: {os.path.relpath(readme_path)}")
            return True
        except OSError as e:
            print(f"Error creating {readme_path}: {e}", file=sys.stderr)
    return False


def scan_repository(repo_root):
    """
    Scans for week-* directories and their problem-* subdirectories.
    Returns a list of dicts with statistics per week.
    """
    entries = sorted(os.listdir(repo_root), key=natural_sort_key)
    week_stats = []

    for entry in entries:
        week_path = os.path.join(repo_root, entry)
        if not os.path.isdir(week_path) or not entry.startswith("week-"):
            continue

        problem_entries = sorted(os.listdir(week_path), key=natural_sort_key)
        problems = []
        for p_entry in problem_entries:
            problem_path = os.path.join(week_path, p_entry)
            if not os.path.isdir(problem_path) or not p_entry.startswith("problem-"):
                continue
            problems.append(problem_path)

        total_problems = len(problems)
        has_main_count = 0
        has_input_count = 0
        completed_count = 0

        for p_path in problems:
            ensure_problem_readme(p_path)

            main_java = os.path.join(p_path, "Main.java")
            input_txt = os.path.join(p_path, "input.txt")

            has_main = os.path.isfile(main_java) and os.path.getsize(main_java) > 0
            has_input = os.path.isfile(input_txt)

            if has_main:
                has_main_count += 1
            if has_input:
                has_input_count += 1
            if has_main:
                completed_count += 1

        if total_problems == 0:
            status = "Not Started"
        elif completed_count == total_problems:
            status = "Completed"
        elif completed_count > 0:
            status = "In Progress"
        else:
            status = "Not Started"

        week_stats.append({
            "week": entry,
            "total": total_problems,
            "main": has_main_count,
            "input": has_input_count,
            "completed": completed_count,
            "status": status,
        })

    return week_stats


def generate_tracker_table(week_stats):
    lines = [
        TRACKER_START_MARKER,
        "| Week | Problems | Main.java | input.txt | Completed | Status |",
        "| :--- | :---: | :---: | :---: | :---: | :--- |",
    ]

    if not week_stats:
        lines.append("| - | 0 | 0 | 0 | 0/0 | No weeks found |")
    else:
        for w in week_stats:
            completed_str = f"{w['completed']}/{w['total']}" if w['total'] > 0 else "0/0"
            lines.append(
                f"| {w['week']} | {w['total']} | {w['main']} | {w['input']} | {completed_str} | {w['status']} |"
            )

    lines.append(TRACKER_END_MARKER)
    return "\n".join(lines)


def update_root_readme(repo_root, week_stats):
    readme_path = os.path.join(repo_root, "README.md")
    tracker_table = generate_tracker_table(week_stats)

    existing_content = ""
    if os.path.exists(readme_path):
        with open(readme_path, "r", encoding="utf-8") as f:
            existing_content = f.read()

    pattern = re.compile(
        re.escape(TRACKER_START_MARKER) + r".*?" + re.escape(TRACKER_END_MARKER),
        re.DOTALL,
    )

    if pattern.search(existing_content):
        new_content = pattern.sub(tracker_table, existing_content)
    else:
        # Append tracker to the README
        sep = "\n\n" if existing_content and not existing_content.endswith("\n\n") else ""
        if existing_content.endswith("\n"):
            sep = "\n"
        new_content = existing_content + sep + "## Progress Tracker\n\n" + tracker_table + "\n"

    if new_content != existing_content:
        with open(readme_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print("Updated Progress Tracker in README.md")
        return True
    else:
        print("Progress Tracker in README.md is already up to date.")
        return False


def main():
    repo_root = get_repo_root()
    week_stats = scan_repository(repo_root)
    update_root_readme(repo_root, week_stats)


if __name__ == "__main__":
    main()
