# Cucumber/Gherkin Test Debugging Setup

This directory contains scripts and configuration files to help debug Cucumber/Gherkin tests in VS Code.

## How It Works

The cucumber tests consist of two parts:
1. **C++ Steps Binary** - Implements the step definitions and runs as a server
2. **Cucumber Ruby** - Reads `.feature` files and communicates with the C++ binary via wire protocol

For debugging, we:
- Launch the C++ steps binary under the debugger with a **fixed socket** (`/tmp/cucumber-debug.sock`)
- Run cucumber separately, connecting to that fixed socket
- Set breakpoints in your C++ step definitions

## Quick Start

### Step 1: Set Breakpoints
Set breakpoints in your step definition files:
- `Calc/features/step_definitions/*.cpp`
- `DataFile/features/step_definitions/*.cpp`

### Step 2: Start Debugging
Press `F5` and select the compound launch configuration:
- **"Debug DataFile (Compound)"** for DataFile tests
- **"Debug Calculator (Compound)"** for Calculator tests

That's it! The compound configuration will automatically:
- Build the test in debug mode
- Clean up any existing socket
- Launch the C++ steps binary under the debugger
- Run cucumber to execute your tests
- Hit your breakpoints

## Files

- `cucumber_debug.wire` - Wire protocol configuration pointing to fixed socket
- `run_cucumber_debug.sh` - Helper script to run cucumber with debug configuration

## Troubleshooting

**Socket already in use:**
The compound configuration should clean this up automatically, but if needed:
```bash
rm -f /tmp/cucumber-debug.sock
```

**Can't find features:**
Make sure you've built the test first:
```bash
bazel build -c dbg //DataFile/features:datafile_test
# Or:
bazel build -c dbg //Calc/features:calc_test
```

**Debugger not hitting breakpoints:**
- Check that debug symbols are enabled (`-c dbg`)
- Verify the source file path matches your workspace
- Try cleaning and rebuilding: `bazel clean && bazel build -c dbg //DataFile/features:datafile_test`