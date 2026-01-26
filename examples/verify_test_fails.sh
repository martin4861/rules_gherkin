#!/usr/bin/env bash
# Script to verify that a test fails as expected
# This is used to test that intentionally failing tests actually fail

set -e

if bazel test //Calc/features:failure_test --test_output=all; then
  echo "ERROR: Test passed but should have failed!"
  exit 1
else
  echo "Test failed as expected"
  exit 0
fi
