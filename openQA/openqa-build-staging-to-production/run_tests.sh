#!/bin/bash
set -euo pipefail

# Unit test runner for openqa-build-staging-to-production using diff

echo "=================================================="
echo "Running build-staging-to-production unit tests..."
echo "=================================================="

STAGING_FILE="examples/staging/staging-e-openqa.cmd"
BUILD_TAG="my-build"
FAILED=0

# Helper function to run a test case
run_test_case() {
    local name="$1"
    local flags="${2:-}"
    local expected_file="tests/expected-${name}.cmd"
    local actual_file="/tmp/actual-${name}.cmd"

    echo -n "Test Case: ${name} ... "

    # Run the script with optional flags
    if [ -z "$flags" ]; then
        ./build-staging-to-production "$STAGING_FILE" "$BUILD_TAG" > "$actual_file"
    else
        ./build-staging-to-production "$STAGING_FILE" "$BUILD_TAG" $flags > "$actual_file"
    fi

    # Compare produced vs expected output using diff
    if diff -Bu "$expected_file" "$actual_file" > /tmp/diff-${name}.log; then
        echo "PASS"
    else
        echo "FAIL"
        echo "--------------------------------------------------"
        echo "Diff log for ${name}:"
        cat /tmp/diff-${name}.log
        echo "--------------------------------------------------"
        FAILED=1
    fi

    # Clean up
    rm -f "$actual_file" "/tmp/diff-${name}.log"
}

# Run the test scenarios
run_test_case "base" "--base"
run_test_case "jeos" "--jeos"
run_test_case "microos" "--microos"
run_test_case "microos-qcow" "--microos-qcow"
run_test_case "net-agama" "--net-agama"
run_test_case "settings" "--base CASEDIR=foo/bar"
run_test_case "host" "--base --host openqa.custom.org"
run_test_case "all" ""

echo "=================================================="
if [ "$FAILED" -eq 0 ]; then
    echo "All tests PASSED successfully!"
    exit 0
else
    echo "Some tests FAILED!"
    exit 1
fi
