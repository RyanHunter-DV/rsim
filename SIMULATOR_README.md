# Simulator Framework

This framework provides a direct way to execute VCS simulator operations (compile, elaborate, run) through a command-line interface.

## Overview

The simulator framework consists of:
- `bins/simulator` - Main executable
- `app/SimApp.rb` - Application logic with direct execution
- `ui/SimUI.rb` - Command-line interface
- `builders/VcsSimulator.rb` - VCS simulator implementation

## Usage

### Basic Usage

```bash
# Set required environment variables
export PROJ_HOME=/path/to/your/project
export OUT_HOME=/path/to/output/directory

# Run complete VCS simulation flow
./bins/simulator --simulator vcs --top-module top_module --filelist filelist.f

# Compile only
./bins/simulator --simulator vcs --compile-only --top-module top_module --filelist filelist.f

# Run only
./bins/simulator --simulator vcs --run-only

# Clean simulation files
./bins/simulator --simulator vcs --clean-only
```

### Command Line Options

#### General Options
- `-v, --verbose LEVEL` - Set verbose level (0-10)
- `-d, --debug [LEVEL]` - Set debug level (0-10)
- `-h, --help` - Show help message
- `-j, --jobs NUMBER` - Set maximum number of jobs
- `-l, --log FILE` - Specify log file name
- `-o, --out HOME` - Specify output home directory
- `--config-dir DIR` - Specify configuration directory

#### Simulator-Specific Options
- `--simulator SIM` - Specify simulator (vcs, xcelium, modelsim)
- `--compile-only` - Only compile, skip elaborate and run
- `--run-only` - Only run, skip compile and elaborate
- `--clean-only` - Only clean simulation files
- `--top-module TOP` - Specify top module name
- `--filelist FILE` - Specify filelist file
- `--defines DEFS` - Comma-separated list of defines
- `--include-dirs DIRS` - Comma-separated list of include directories
- `--source-files FILES` - Comma-separated list of source files
- `--comp_opt OPTIONS` - Specify VCS compilation options (direct string)
- `--elab_opt OPTIONS` - Specify VCS elaboration options (direct string)
- `--sim_opt OPTIONS` - Specify VCS simulation options (direct string)
- `--testname TEST` - Specify test name in testsuite/testname format
- `--full64` - Enable 64-bit mode
- `--debug` - Enable debug mode
- `--verbose` - Enable verbose output

### Environment Variables

The framework uses these environment variables:
- `PROJ_HOME` - Project home directory (required)
- `OUT_HOME` - Output directory (defaults to `$PROJ_HOME/out`)
- `SOURCE_FILES` - Source files for compilation
- `TOP_MODULE` - Top module name
- `TESTBENCH` - Testbench module name
- `DEFINES` - Compiler defines
- `INCLUDE_DIRS` - Include directories
- `COMPILE_OPTIONS` - Additional compile options
- `ELABORATE_OPTIONS` - Additional elaborate options
- `RUN_OPTIONS` - Additional run options
- `FULL64` - Enable 64-bit mode
- `DEBUG` - Enable debug mode
- `VERBOSE` - Enable verbose output

### Available Actions

#### sim (default)
Complete VCS simulation flow (compile + elaborate + run)

#### compile_only
VCS compilation only

#### run_only
VCS simulation run only

#### clean_only
Clean simulation files

### VCS Options Structure

The framework organizes VCS options into three categories:

#### Compile Options (`--comp_opt`)
Direct VCS compilation options passed as strings:
```bash
--comp_opt "-sverilog -timescale=1ns/1ps"
--comp_opt "+define+DEBUG" --comp_opt "+incdir+/path/to/includes"
```

#### Elaborate Options (`--elab_opt`)
Direct VCS elaboration options passed as strings:
```bash
--elab_opt "-debug_all"
--elab_opt "-full64 -v2k"
```

#### Simulation Options (`--sim_opt`)
Direct VCS simulation options passed as strings:
```bash
--sim_opt "+v2k -l sim.log"
--sim_opt "-gui -do run.do"
```

### Examples

#### Simple Simulation
```bash
export PROJ_HOME=/path/to/project
./bins/simulator --simulator vcs --top-module top_module --filelist filelist.f
```

#### Simulation with Defines and Include Directories
```bash
./bins/simulator --simulator vcs \
  --top-module top_module \
  --filelist filelist.f \
  --defines DEBUG,VERBOSE \
  --include-dirs /path/to/includes,/path/to/more/includes
```

#### Simulation with VCS Options
```bash
./bins/simulator --simulator vcs \
  --top-module top_module \
  --filelist filelist.f \
  --comp_opt "-sverilog -timescale=1ns/1ps" \
  --elab_opt "-debug_all" \
  --sim_opt "+v2k -l sim.log"
```

#### Debug Simulation
```bash
./bins/simulator --simulator vcs \
  --top-module top_module \
  --filelist filelist.f \
  --debug \
  --full64 \
  --verbose
```

#### Compile Only
```bash
./bins/simulator --simulator vcs --compile-only --top-module top_module --filelist filelist.f
```

#### Run Only
```bash
./bins/simulator --simulator vcs --run-only
```

## Extending the Framework

### Adding New Simulators

1. Create a new simulator class in `builders/` (e.g., `XceliumSimulator.rb`)
2. Add simulator-specific options to `SimUI.rb`
3. Add simulator execution logic to `SimApp.rb`

### Adding New Operations

1. Add new methods to the simulator class
2. Add new action flags to `SimUI.rb`
3. Add new execution logic to `SimApp.rb`

### Customizing VCS Options

The `VcsSimulator` class can be extended to support additional VCS-specific options by:
1. Adding new attributes to the class
2. Updating the command building methods
3. Adding new parameters to the UI options

## File Structure

```
├── bins/
│   └── simulator          # Main executable
├── app/
│   └── SimApp.rb         # Application logic with direct execution
├── ui/
│   └── SimUI.rb          # Command-line interface
└── builders/
    └── VcsSimulator.rb   # VCS simulator implementation
```

## Logging

The framework provides comprehensive logging:
- Main log: `$OUT_HOME/simulator.log`
- Debug log: `$OUT_HOME/simulator_debug.log`
- Simulation log: `$OUT_HOME/sim/sim.log`

Use the `-v` and `-d` options to control logging verbosity. 