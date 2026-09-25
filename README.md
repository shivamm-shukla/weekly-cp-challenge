# Weekly CP Challenge

A dedicated repository tracking my weekly competitive programming practice, algorithmic problem solving, and contest solutions implemented in Java.

The goal is to maintain consistency, analyze time and space complexity, and build strong problem-solving patterns across various data structures and algorithms.

## Progress Tracker

<!-- AUTO-TRACKER:START -->
| Week | Problems | Main.java | input.txt | Completed | Status |
| :--- | :---: | :---: | :---: | :---: | :--- |
| week-1 | 4 | 4 | 4 | 4/4 | Completed |
| week-2 | 0 | 0 | 0 | 0/0 | Not Started |
| week-3 | 4 | 2 | 4 | 2/4 | In Progress |
<!-- AUTO-TRACKER:END -->

## Repository Structure

Problems are organized by week, with each challenge maintained in its own self-contained directory:

```text
weekly-cp-challenge/
├── week-1/
│   └── problem-1/
│       ├── README.md       # Problem summary, approach, algorithm & complexities
│       ├── Main.java       # Clean Java solution
│       └── input.txt       # Sample / edge-case test input (single-test format)
├── week-3/
│   └── problem-1/
│       ├── README.md       # Problem description, summary & editorial
│       ├── Main.java       # Java solution
│       └── tests/          # Comprehensive test suite
│           ├── sample/     # Public sample tests (*.in, *.ans)
│           └── secret/     # Secret test cases (*.in, *.ans)
├── run.sh                  # Universal runner (auto-delegates to run_tests.sh when tests/ exists)
├── run_tests.sh            # Multi-test runner with automated diffing & summary
└── scripts/
    ├── update_tracker.py   # Progress tracker updater
    └── watch.sh            # Inotify watcher daemon
```

Each problem directory contains:
- **`README.md`**: Problem URL, summary, intuition, algorithm breakdown, and asymptotic time/space complexities.
- **`Main.java`**: Structured Java solution using standard input/output.
- **`tests/`** (or **`input.txt`**):
  - `tests/sample/`: Sample test cases (`.in` input and `.ans` expected output).
  - `tests/secret/`: Secret / edge test cases (`.in` input and `.ans` expected output).
  - `input.txt`: Single input file for earlier practice problems.

## Running Solutions Locally

You can test solutions using either `run_tests.sh` (specialized test suite runner) or `run.sh` (universal problem runner).

Both scripts compile the solution in an isolated temporary directory (`/tmp`) so no `.class` build artifacts pollute your workspace.

### 1. Test Suite Runner (`run_tests.sh`)

Use `run_tests.sh` to compile and test a solution against multiple test cases, showing input, expected output, actual output (on failure), and a PASS/FAIL summary:

```bash
# Run against a problem directory
./run_tests.sh week-3/problem-1

# Run by specifying the Java solution file
./run_tests.sh week-3/problem-1/Main.java

# Run directly from inside the problem directory
cd week-3/problem-1 && ../../run_tests.sh

# Run older single-input problems (backward compatible)
./run_tests.sh week-1/problem-1
```

#### Helpful Flags

- **`--compact` (`-c`)**: Shows full input/output details only for failing test cases; passed cases show a concise status line.
  ```bash
  ./run_tests.sh --compact week-3/problem-1
  ```
- **`--all` (`-a`)**: Displays complete input and output for large test cases without truncating at 20 lines.
  ```bash
  ./run_tests.sh --all week-3/problem-1
  ```
- **`--timeout <seconds>` (`-t`)**: Sets execution timeout per test case (default: `5s`) to catch infinite loops.
  ```bash
  ./run_tests.sh --timeout 10 week-3/problem-1
  ```

### 2. Universal Runner (`run.sh`)

`run.sh` works seamlessly across all weeks:
- If `tests/` exists, it automatically delegates to `run_tests.sh`.
- If `input.txt` exists, it executes the solution with standard input.

```bash
./run.sh week-1/problem-1   # executes with input.txt
./run.sh week-3/problem-1   # automatically runs all tests via run_tests.sh
```
