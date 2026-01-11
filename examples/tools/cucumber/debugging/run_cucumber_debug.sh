#!/bin/bash
set -e

# Usage: ./run_cucumber_debug.sh [datafile_test|calc_test]
TEST_TARGET="${1:-datafile_test}"

# Set up paths
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

# Determine the test directory based on the target
if [[ "$TEST_TARGET" == "datafile_test" ]]; then
    TEST_DIR="DataFile/features"
    STEPS_DIR="DataFile/features/step_definitions"
elif [[ "$TEST_TARGET" == "calc_test" ]]; then
    TEST_DIR="Calc/features"
    STEPS_DIR="Calc/features/step_definitions"
else
    echo "ERROR: Unknown test target: ${TEST_TARGET}"
    echo "Usage: $0 [datafile_test|calc_test]"
    exit 1
fi

RUNFILES_DIR="${WORKSPACE_ROOT}/bazel-bin/${TEST_DIR}/${TEST_TARGET}.sh.runfiles"
CUCUMBER_RUBY="${RUNFILES_DIR}/rules_gherkin+/cucumber_ruby.sh"
FEATURE_DIR="${RUNFILES_DIR}/_main/${TEST_DIR}"
WIRE_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create a temporary working directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

# Export required environment variables
export RUNFILES_DIR="${RUNFILES_DIR}"
export HOME="${HOME:-/tmp}"

echo "=========================================="
echo "Running Cucumber in debug mode"
echo "Test target: ${TEST_TARGET}"
echo "Features: ${FEATURE_DIR}"
echo "Working dir: ${TEMP_DIR}"
echo "Socket: /tmp/cucumber-debug.sock"
echo "=========================================="
echo ""
echo "Make sure the debugger is already running!"
echo "Waiting for socket to be available..."

# Wait for the socket to be created by the debugger
for i in {1..30}; do
  if [ -S /tmp/cucumber-debug.sock ]; then
    echo "Socket found! Starting cucumber..."
    break
  fi
  echo "Waiting for socket... ($i/30)"
  sleep 1
done

if [ ! -S /tmp/cucumber-debug.sock ]; then
  echo "ERROR: Socket /tmp/cucumber-debug.sock not found!"
  echo "Make sure to start the debugger first!"
  exit 1
fi

# Set up the temporary directory structure
mkdir -p "${TEMP_DIR}/features/step_definitions"
mkdir -p "${TEMP_DIR}/features/support"

# Copy wire config to temp directory
cp "${WIRE_CONFIG_DIR}/cucumber_debug.wire" "${TEMP_DIR}/features/step_definitions/calculator_step.wire"

# Create support file for wire protocol
echo "require 'cucumber/wire'" > "${TEMP_DIR}/features/support/require_wire.rb"

# Symlink all feature files to our temp directory
for feature in "${FEATURE_DIR}/features"/*.feature; do
  if [ -e "$feature" ]; then
    ln -sf "$feature" "${TEMP_DIR}/features/"
  fi
done

# Run cucumber from the temp directory, pointing to the feature files
cd "${TEMP_DIR}"
"${CUCUMBER_RUBY}" -v -r "${TEMP_DIR}" "${TEMP_DIR}/features"

echo ""
echo "=========================================="
echo "Cucumber run completed"
echo "=========================================="