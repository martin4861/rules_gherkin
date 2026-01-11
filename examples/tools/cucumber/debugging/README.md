# Cucumber/Gherkin Test Debugging Setup

This directory contains scripts and configuration files to help debug Cucumber/Gherkin tests in VS Code or from the command line.

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

### Step 2: Start Debugger
Press `F5` and select:
- **"Debug Cucumber Steps (Fixed Socket)"**

The debugger will:
- Build the test in debug mode
- Launch the steps binary listening on `/tmp/cucumber-debug.sock`
- Wait for cucumber to connect

### Step 3: Run Cucumber
Open a **new terminal** and run:
```bash
# Press Cmd+Shift+P → Tasks: Run Task
# Select: "run_cucumber_debug_script"
```

Or manually:
```bash
./tools/cucumber/debugging/run_cucumber_debug.sh datafile_test

# Or for calc_test:
./tools/cucumber/debugging/run_cucumber_debug.sh calc_test
```

The cucumber tests will now run and hit your breakpoints!

## Files

- `cucumber_debug.wire` - Wire protocol configuration pointing to fixed socket
- `run_cucumber_debug.sh` - Helper script to run cucumber with debug configuration

## Tips

- The steps binary must be running (in debugger) BEFORE you start cucumber
- The script waits up to 30 seconds for the socket to be available
- Use `--verbose` to see detailed wire protocol communication (already configured)
- Test data files are automatically available via Bazel runfiles

## Troubleshooting

**Socket already in use:**
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