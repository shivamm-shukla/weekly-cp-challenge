# weekly-cp-challenge

Java solutions to weekly competitive programming contests, organized systematically by week and problem.

## Progress Tracker

<!-- AUTO-TRACKER:START -->
| Week | Problems | Main.java | input.txt | Completed | Status |
| :--- | :---: | :---: | :---: | :---: | :--- |
| week-1 | 4 | 1 | 1 | 1/4 | In Progress |
| week-2 | 0 | 0 | 0 | 0/0 | Not Started |
<!-- AUTO-TRACKER:END -->

## Repository Structure

```text
weekly-cp-challenge/
├── README.md                 # Root documentation and auto-updating progress tracker
├── run.sh                    # Runner script to compile & execute solutions in a sandbox
├── scripts/
│   ├── update_tracker.sh     # Manual & hook entry point to refresh tracker table
│   ├── update_tracker.py     # Scanner and tracker generation logic
│   ├── watch.sh              # Background inotify watcher daemon controller
│   └── watcher.py            # Real-time directory and file watcher
├── week-1/
│   ├── problem-1/
│   │   ├── README.md         # Problem notes, complexities, and approach
│   │   ├── Main.java         # Java solution
│   │   └── input.txt         # Sample test input
│   └── ...
└── week-2/
```

## Quick Start & Workflow

### 1. Adding a New Problem
Create your problem directory and files using standard Linux commands:

```bash
mkdir -p week-1/problem-1
touch week-1/problem-1/Main.java
touch week-1/problem-1/input.txt
```

If the background watcher is running, `README.md` is automatically created with boilerplate sections. If not, it will be automatically created on the next tracker update or commit.

### 2. Running Solutions
Use the root [`run.sh`](run.sh) script to compile and run your solution against `input.txt`. This compiles to a temporary directory (`/tmp`) to keep problem folders clean of `.class` files:

```bash
./run.sh week-1/problem-1
```

### 3. Background File Watcher
The watcher uses Linux native `inotify` to react in real time to `mkdir` and file edits:

```bash
./scripts/watch.sh start    # Start background watcher
./scripts/watch.sh status   # Check status
./scripts/watch.sh stop     # Stop background watcher
./scripts/watch.sh run      # Run in foreground
```

### 4. Git Commit & Automation
A Git `pre-commit` hook is installed in `.git/hooks/pre-commit`. Whenever you commit, the tracker automatically scans all weeks and updates the progress table above before finalizing the commit.
