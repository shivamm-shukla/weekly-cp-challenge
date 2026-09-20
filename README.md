# Weekly CP Challenge

A dedicated repository tracking my weekly competitive programming practice, algorithmic problem solving, and contest solutions implemented in Java.

The goal is to maintain consistency, analyze time and space complexity, and build strong problem-solving patterns across various data structures and algorithms.

## Progress Tracker

<!-- AUTO-TRACKER:START -->
| Week | Problems | Main.java | input.txt | Completed | Status |
| :--- | :---: | :---: | :---: | :---: | :--- |
| week-1 | 4 | 4 | 4 | 4/4 | Completed |
| week-2 | 0 | 0 | 0 | 0/0 | Not Started |
<!-- AUTO-TRACKER:END -->

## Repository Structure

Problems are organized by week, with each challenge maintained in its own self-contained directory:

```text
weekly-cp-challenge/
├── week-1/
│   ├── problem-1/
│   │   ├── README.md       # Problem summary, approach, algorithm & complexities
│   │   ├── Main.java       # Clean Java solution
│   │   └── input.txt       # Sample / edge-case test input
│   └── ...
└── ...
```

Each problem directory contains:
- **`README.md`**: Problem URL, summary, intuition, algorithm breakdown, and asymptotic time/space complexities.
- **`Main.java`**: Structured Java solution using standard input/output.
- **`input.txt`**: Sample and edge-case inputs for local validation.

## Running Solutions Locally

Solutions can be compiled and executed directly from the repository root against their corresponding input using the runner script:

```bash
./run.sh week-1/problem-1
```

This compiles the solution in an isolated temporary directory, executes it with `input.txt` via standard input, and ensures no build artifacts (`.class` files) pollute the repository.
