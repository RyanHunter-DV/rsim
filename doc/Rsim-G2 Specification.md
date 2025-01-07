# Feature description
[[ToolRequirements]]
# Actions to do
- [ ] plugin manager will be removed, all generator chain commands will be defined in Rsim module.
- [ ] regression flow requires Rsim module has the ability to call buildflow, simflow etc directly.

# file structure
`./out`, the out path, can be changed through the env var: `$OUT`
`./out/configs/`, root path to store all built configs
`./out/configs/<configname>/components`, root path to store all built components for certain config.
`./out/configs/<configname>/run/<testsuite>/<testname>`, path for different tests, such as waveform, simulation log, command etc.
`./out/logs/...`
`./out/configs/<configname>/features/...`, global feature folder for certain config
`./out/configs/<configname>/components/<component-inst0.inst1.xxx>/features/...`, local feature for components.

# Main tool procedures
## init
1. ui system
2. report & log system
3. job control system
4. ipxact system
## run
1. get required chain from ui system
	1. chain name required, steps to be skipped
2. call chain's execute name, for example, the buildflow chain may have build execute name.

# ui system
1. the first initialized system, process user inputs and env variables.
2. select required chains
3. for help and version message, just declared in the ui system and will be reported immediately.
# report system
1. prepare apis for info, warning, error message printing
2. all messages will be logged to the main log file.
3. build log file procedures at init
	1. require ui system for out path, verbosity, and log file name.
