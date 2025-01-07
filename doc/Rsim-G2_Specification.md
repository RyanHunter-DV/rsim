# Feature description
[[doc/ToolRequirements]]
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
5. OS system, call os based commands such as make directory.
## run
1. get required chain from ui system
	1. chain name required, steps to be skipped
2. call chain's execute name, for example, the buildflow chain may have build execute name.

# ui system
the first initialized system, process user inputs and env variables.
1. call optparser to parse user inputs.
2. select required chains
3. for help and version message, just declared in the ui system and will be reported immediately.
# report system
1. prepare apis for info, warning, error message printing
2. all messages will be logged to the main log file.
3. build log file procedures at init
	1. require ui system for out path, verbosity, and log file name.

# os system
The os system used by programmer to achieve operations related with operation system, such like to make directory, remove or link files etc.
This object will be a class and instantiated in Rsim module, all apis can be called through: `Rsim.os.<api>`
1. initialize procedures:
	2. setup current os type, if is linux or windows or others...
	3. setup other key required configs or information from ui system.
# job control system
The job control system let users to build a new Proc or system commands by creating a new job object, and manage it with unified apis.
## internal proc job control
The job control system supports two types of jobs, one is internal process, which has no job number limits.
1. create a new job object and give it the Proc, and a unique name;
	1. job object automatically update status int JobM module, with the self job object.
	2. set status to run before eval the given Proc, and set status to finished after the given Proc.
2. if other sub process or main process require to wait the job done, just find it and call job.wait.
## os system job control
The system job will be executed first to build the cmd file, then to source the cmd file.
For multiple commands, use ';' to separate it in one giving string. Each separated command will be built as a line in cmd file.
for example `cmda;cmdb` will be built like below in cmd file
```
# cmd file
cmda
cmdb
```
And finally, the source command will be executed through the [[doc/rsim-job-anchor]] to add job anchor files and logs while running the command

# ipxact system
The ipxact system will have a top class object which will be created and initialized in Rsim's init phase, and it can be invoked through `Rsim.ipx` api.
After initialized, the ui system will give out the chain running steps and corresponding options, which will be called in Rsim.run like:
```ruby
@ipxact.loading @ui.flowNames;
flows=@ui.flowStream; # {:node=>{options....}, :build => {:a=>:b,:c=>:d,...,:skips=>[a,b,..]}}
flows.each_pair do |n,opts|
	@ipxact.send(n.to_sym,opts);
end
```
## loading chain definitions
Before the ipxact can execute all different chains, the required chain definitions shall be loaded first.
During the Rsim.init, after ui system initialized, the ipxact system's init step will require ui system's flowNames (is the execute name, the ipxact loading system will automatically add the 'flow' suffix')
## executing chains
Once the required chains are loaded, using a string based command with hash options can call to execute the specific chain, like:
`ipxact.send(:build,options)`
## chain options while executing
#TODO , detailed options support for common chains
- 'skip', used to specify which generator step will be skipped, this option supports by all chains.
