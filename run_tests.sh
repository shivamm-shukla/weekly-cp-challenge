#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# run_tests.sh - Competitive Programming Test Runner for Java Solutions
# ==============================================================================
# Supports:
# 1. Multi-test setup:
#    - Problem directory containing Main.java and tests/ folder
#    - tests/sample/ and tests/secret/ containing *.in and matching *.ans files
# 2. Older setup (backward compatible):
#    - Problem directory containing Main.java and input.txt
# ==============================================================================

# ANSI Color configuration (disabled if not connected to a terminal or NO_COLOR is set)
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    GREEN="\033[1;32m"
    RED="\033[1;31m"
    YELLOW="\033[1;33m"
    CYAN="\033[1;36m"
    BOLD="\033[1m"
    NC="\033[0m"
else
    GREEN=""
    RED=""
    YELLOW=""
    CYAN=""
    BOLD=""
    NC=""
fi

SHOW_ALL=false
COMPACT_MODE=false
TIMEOUT_SEC=5
TARGET=""
TESTS_DIR_OVERRIDE=""

show_usage() {
    echo -e "${BOLD}Usage:${NC} $0 [options] <path/to/problem-directory | path/to/Main.java> [path/to/tests]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo -e "  -a, --all               Show full input/output without truncating large files (>25 lines)"
    echo -e "  -c, --compact           Compact view (show input/output details only for FAIL cases)"
    echo -e "  -t, --timeout <seconds> Set execution timeout per test case in seconds (default: 5)"
    echo -e "  -h, --help              Show this help message"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo -e "  $0 week-3/problem-1"
    echo -e "  $0 week-3/problem-1/Main.java"
    echo -e "  $0 --compact week-3/problem-1"
    echo -e "  $0 week-1/problem-1          # Runs older setup with input.txt"
    echo -e "  (cd week-3/problem-1 && ../../run_tests.sh)"
}

# Parse options
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -a|--all)
            SHOW_ALL=true
            shift
            ;;
        -c|--compact)
            COMPACT_MODE=true
            shift
            ;;
        -t|--timeout)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: --timeout requires a duration in seconds.${NC}" >&2
                exit 1
            fi
            TIMEOUT_SEC="$2"
            shift 2
            ;;
        -*)
            echo -e "${RED}Error: Unknown option '$1'.${NC}" >&2
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$TARGET" ]; then
                TARGET="$1"
            elif [ -z "$TESTS_DIR_OVERRIDE" ]; then
                TESTS_DIR_OVERRIDE="$1"
            else
                echo -e "${RED}Error: Too many arguments provided.${NC}" >&2
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# If no target specified, check current working directory
if [ -z "$TARGET" ]; then
    if [ -f "./Main.java" ]; then
        TARGET="."
    else
        show_usage
        exit 1
    fi
fi

# Resolve TARGET_DIR and MAIN_FILE
if [ -d "$TARGET" ]; then
    TARGET_DIR="${TARGET%/}"
    MAIN_FILE="$TARGET_DIR/Main.java"
elif [ -f "$TARGET" ]; then
    MAIN_FILE="$TARGET"
    TARGET_DIR="$(dirname "$MAIN_FILE")"
else
    echo -e "${RED}Error: Target path '$TARGET' does not exist.${NC}" >&2
    exit 1
fi

if [ ! -f "$MAIN_FILE" ]; then
    echo -e "${RED}Error: Solution file '$MAIN_FILE' not found.${NC}" >&2
    exit 1
fi

CLASS_NAME="$(basename "$MAIN_FILE" .java)"
INPUT_FILE="$TARGET_DIR/input.txt"

if [ -n "$TESTS_DIR_OVERRIDE" ]; then
    TESTS_DIR="${TESTS_DIR_OVERRIDE%/}"
else
    TESTS_DIR="$TARGET_DIR/tests"
fi

# Print content with line limit handling
print_content() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "(empty)"
        return
    fi
    if [ ! -s "$file" ]; then
        echo "(empty)"
        return
    fi

    local line_count
    line_count=$(wc -l < "$file" 2>/dev/null || echo 0)
    if [ "$line_count" -eq 0 ] && [ -s "$file" ]; then
        line_count=1
    fi

    if [ "$SHOW_ALL" = true ] || [ "$line_count" -le 25 ]; then
        cat "$file"
        if [ "$(tail -c 1 "$file" 2>/dev/null)" != "" ]; then
            echo ""
        fi
    else
        head -n 20 "$file"
        echo -e "${YELLOW}... [truncated: showing first 20 of $line_count lines; use --all to view full content]${NC}"
    fi
}

# Compile in temporary directory
TMP_BIN="$(mktemp -d /tmp/cp_runner_XXXXXX)"
trap 'rm -rf "$TMP_BIN"' EXIT

echo -e "${CYAN}${BOLD}==> Compiling $MAIN_FILE...${NC}"
if ! javac -d "$TMP_BIN" "$MAIN_FILE"; then
    echo -e "${RED}Error: Compilation failed for '$MAIN_FILE'.${NC}" >&2
    exit 2
fi
echo -e "${GREEN}==> Compilation successful.${NC}\n"

PASS_COUNT=0
FAIL_COUNT=0

# Check whether this is multi-test mode or older setup mode (single input.txt)
if [ -d "$TESTS_DIR" ]; then
    # Collect all test cases
    TEST_FILES=()

    # 1. Sample tests first
    if [ -d "$TESTS_DIR/sample" ]; then
        while IFS= read -r f; do
            [ -n "$f" ] && TEST_FILES+=("$f")
        done < <(find "$TESTS_DIR/sample" -maxdepth 1 -name "*.in" | sort -V)
    fi

    # 2. Secret tests next
    if [ -d "$TESTS_DIR/secret" ]; then
        while IFS= read -r f; do
            [ -n "$f" ] && TEST_FILES+=("$f")
        done < <(find "$TESTS_DIR/secret" -maxdepth 1 -name "*.in" | sort -V)
    fi

    # 3. Any remaining .in files in tests directory
    while IFS= read -r f; do
        [ -n "$f" ] && TEST_FILES+=("$f")
    done < <(find "$TESTS_DIR" -name "*.in" ! -path "$TESTS_DIR/sample/*" ! -path "$TESTS_DIR/secret/*" | sort -V)

    if [ "${#TEST_FILES[@]}" -eq 0 ]; then
        echo -e "${RED}Error: No .in test cases found in '$TESTS_DIR'.${NC}" >&2
        exit 1
    fi

    TOTAL_COUNT="${#TEST_FILES[@]}"
    echo -e "${BOLD}Running $TOTAL_COUNT test cases from $TESTS_DIR...${NC}"

    for in_file in "${TEST_FILES[@]}"; do
        # Determine expected output file (.ans or fallback .out)
        ans_file="${in_file%.in}.ans"
        if [ ! -f "$ans_file" ] && [ -f "${in_file%.in}.out" ]; then
            ans_file="${in_file%.in}.out"
        fi

        test_rel_path="${in_file#$TESTS_DIR/}"
        test_display_name="${test_rel_path%.in}"
        ACTUAL_OUT_FILE="$TMP_BIN/actual.out"
        ACTUAL_ERR_FILE="$TMP_BIN/actual.err"
        : > "$ACTUAL_OUT_FILE"
        : > "$ACTUAL_ERR_FILE"

        set +e
        timeout "${TIMEOUT_SEC}s" java -cp "$TMP_BIN" "$CLASS_NAME" < "$in_file" > "$ACTUAL_OUT_FILE" 2> "$ACTUAL_ERR_FILE"
        RUN_EXIT=$?
        set -e

        IS_PASS=false
        FAIL_REASON=""

        if [ "$RUN_EXIT" -eq 124 ]; then
            FAIL_REASON="Time Limit Exceeded (${TIMEOUT_SEC}s)"
        elif [ "$RUN_EXIT" -ne 0 ]; then
            FAIL_REASON="Runtime Error (exit code $RUN_EXIT)"
        elif [ ! -f "$ans_file" ]; then
            FAIL_REASON="Expected output file missing (${in_file%.in}.ans)"
        elif diff -u -Z -B --strip-trailing-cr "$ACTUAL_OUT_FILE" "$ans_file" > /dev/null 2>&1; then
            IS_PASS=true
        else
            FAIL_REASON="Wrong Answer"
        fi

        echo "------------------------------------------------------------"
        if [ "$IS_PASS" = true ]; then
            echo -e "${GREEN}[PASS]${NC} ${BOLD}$test_display_name${NC}"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "${RED}[FAIL]${NC} ${BOLD}$test_display_name${NC} - ${RED}${FAIL_REASON}${NC}"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi

        if [ "$COMPACT_MODE" = false ] || [ "$IS_PASS" = false ]; then
            echo -e "${CYAN}--- Input ---${NC}"
            print_content "$in_file"

            echo -e "${CYAN}--- Expected Output ---${NC}"
            if [ -f "$ans_file" ]; then
                print_content "$ans_file"
            else
                echo -e "${YELLOW}[Expected output file missing: $ans_file]${NC}"
            fi

            if [ "$IS_PASS" = false ]; then
                echo -e "${CYAN}--- Actual Output ---${NC}"
                if [ "$RUN_EXIT" -eq 124 ]; then
                    echo -e "${RED}[Execution timed out after ${TIMEOUT_SEC} seconds]${NC}"
                fi
                if [ -s "$ACTUAL_ERR_FILE" ]; then
                    echo -e "${YELLOW}[stderr]:${NC}"
                    print_content "$ACTUAL_ERR_FILE"
                fi
                if [ -s "$ACTUAL_OUT_FILE" ]; then
                    print_content "$ACTUAL_OUT_FILE"
                elif [ "$RUN_EXIT" -ne 124 ] && [ ! -s "$ACTUAL_ERR_FILE" ]; then
                    echo -e "${YELLOW}[No output produced]${NC}"
                fi
            fi
        fi
    done

elif [ -f "$INPUT_FILE" ]; then
    # Older setup compatibility: single input.txt
    TOTAL_COUNT=1
    echo -e "${YELLOW}==> Older setup detected: running with $INPUT_FILE${NC}"

    ACTUAL_OUT_FILE="$TMP_BIN/actual.out"
    ACTUAL_ERR_FILE="$TMP_BIN/actual.err"
    : > "$ACTUAL_OUT_FILE"
    : > "$ACTUAL_ERR_FILE"

    set +e
    timeout "${TIMEOUT_SEC}s" java -cp "$TMP_BIN" "$CLASS_NAME" < "$INPUT_FILE" > "$ACTUAL_OUT_FILE" 2> "$ACTUAL_ERR_FILE"
    RUN_EXIT=$?
    set -e

    echo "------------------------------------------------------------"
    if [ "$RUN_EXIT" -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} ${BOLD}input.txt${NC}"
        PASS_COUNT=1
    else
        echo -e "${RED}[FAIL]${NC} ${BOLD}input.txt${NC} - Runtime Error (exit code $RUN_EXIT)"
        FAIL_COUNT=1
    fi

    echo -e "${CYAN}--- Input ($INPUT_FILE) ---${NC}"
    print_content "$INPUT_FILE"

    echo -e "${CYAN}--- Actual Output ---${NC}"
    if [ -s "$ACTUAL_ERR_FILE" ]; then
        echo -e "${YELLOW}[stderr]:${NC}"
        print_content "$ACTUAL_ERR_FILE"
    fi
    if [ -s "$ACTUAL_OUT_FILE" ]; then
        print_content "$ACTUAL_OUT_FILE"
    elif [ ! -s "$ACTUAL_ERR_FILE" ]; then
        echo -e "${YELLOW}[No output produced]${NC}"
    fi

else
    echo -e "${RED}Error: Neither tests directory '$TESTS_DIR' nor input file '$INPUT_FILE' found.${NC}" >&2
    exit 1
fi

echo "============================================================"
echo -e "${BOLD}TEST SUMMARY${NC}"
echo "============================================================"
echo "Total Tests : $TOTAL_COUNT"
echo -e "Passed      : ${GREEN}${PASS_COUNT}${NC}"
echo -e "Failed      : ${RED}${FAIL_COUNT}${NC}"
echo "============================================================"

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
else
    exit 0
fi
