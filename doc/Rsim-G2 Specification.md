# Feature description

- Easy for functional simulation.
	- Building the standard HDL (verilog) and TB (systemverilog + cpp) files.
	- Compiling the standard HDL+TB files, with user given extra options.
	- Simulation with compiled database with user given extra options.
- Regression and report collection.
	- #TBD , covreage report, tag based regression
- Based on IP-XACT protocol.
- compatible with XML format database.
- Prepare for Original-G1 project
	- *require bootenv*

## Building features
The building flow, means all building mechanism from a manual specified source format files into standard, EDA supported HDL and TB files.
Rsim tool generically declare a common API that let third party plugins can be invoked and generated to target files and places.
The building is:
1. call thrid party and self built-in to evaluate source code into IP-XACT compatible xml(or other formats) database.
2. use generator to build into standard HDL and DV files.
The standard build file structure shall be like:
![](../../../05-MiscAttatchments/Pasted%20image%2020241129170408.png)
### Build flow
1. user call rsim with build options, and with given config name.
2. the root.rh must be given in ENV variable at least one root entry is required, multiple root entries are supported by separator ','.
3. loading node files
	1. root node -> required nodes by `rhload` command.
	2. next root node if has ... repeat steps 1.
4. evaluating loaded nodes, build nodes into IP-XACT database, xml formatted files and required scripts and tools.
	1. evaluate designConfiguration by command line.
	2. evaluate design top and interconnection information with configurations in designConfiguration
	3. evaluate required components, added by need command in configuration, with corresponding component parameters.
		1. view configurations
		2. parameter settings
	4. evaluate generator chain, with configs.
5. building nodes into IP-XACT database, xml formatted files and required scripts and tools (optional step)
6. call generator chain to start generating target HDL & DV files according to the built IP-XACT database.
	1. generator chain will also build compile and elab commands for next compiling flow.
### Easy embeding plugins
the Rsim is a major shell that can encapsulate many third party plugins to support building the target standard HDL files.
#TODO think how to embed any plugins into the main shell.

### Build to XML format database
1. Can generate source IP-XACT based concepts into xml database, the source IP-XACT base concepts are set through .rh files with Rsim provided commands, such as: `config, component .... do-end, ...`
2. Can read from xml files and along with local .rh files to build xml database.
3. The third party plugins are not user developed, instead, they are all built by Rsim tool developers, so the plugins can only work for Rsim tool, just an easy way to embeded and developed.
In building flow, the tool will first translate information given with `config, component ...` codes into xml files, and with those database, to generate target HDL files for EDA.

**Build component xmls**
According source component information, to build component xml, detailed specifications are located in: 
#TBD [Component node](node/Component%20node.md)

**Build design xml**
Detailed specification in <Design node/>
Now supports concepts of:
- VLNV
- componentInstances, all instanced component identifier.
- interconnections, bus connections between components.
- adHocConnections, the component ports connections.
- 
**Build interface xmls**
**Build generator chain**
1. build generators for each component.
2. build top generator
**Build design configurations**

## Compiling

#TBD


# Tool architecture
![](../../../05-MiscAttatchments/Pasted%20image%2020241202191705.png)
<center>Tool execute flow</center>

## UI system
The UI system reads commands and other user operations (such as ctrl-c) to invoke user actions to Rsim Configuration system, actions can be:
1. ctrl-c, while Rsim is running, manually want to cancel the running job.
2. build command with options, to build standard HDL files.
3. compile command with options, 
4. sim command with options,
5. regression command
When captured different type of exceptions, UI system will help process the exceptions.
```ruby
# app.rb
begin
	Exe.run
	rescue SignalException => e
		@ui.receive(e)
	rescue ...
end
```
## Configuration system
Configuration system stores tool settings:
1. user settings/options from UI system, to update into the configure system.
2. env settings stored when in initialization
3. configure checking when initialized.
4. configure checking every time ui updates the tool settings.
5. provide different configures to other systems, passively given like: `config.get(:option)`

## Execute system
The main executor, kernal started by App by calling the run method.
- The executor will execute different flows and steps according to the loaded plugins.
	- A plugin is treated as a flow with many steps and some configurations.
- Each flow must run in serial mode, while each steps can be dispatched in parallel, details in [flow and step](#flow%20and%20step) chapter.
- Dynamically load the flow plugins according to required flows from Configuration.
### ExecSystem
**run**
```ruby
def run
	config.commands.each_pair do |cmd,opts|
		# cmd: buildflow
		# opts: {'-s' => true,'-c' => 'xxx',...}
		flow.run(cmd,opts)
	end
```
Called by the App module, will start running flows according to the configure system's commands and options.
The flow is the plugin manager, call run of the flow with given command, will first check if the command exists or not, if flow not exists, then will first to load the flow, and then call run of that flow.
### FlowManager
Control and load the different user flows, while called by the run API, it will first check if corresponding flow is loaded or not, if not, need load first, then call the loaded flow's run with options.
## Rsim
The application module, which is the core running panel to initialize all above systems such as the UI, Configuration, Executor etc.
1. init all systems.
2. call Rsim Executor to run program.
3. load and provide message printer.
**init**
All systems are initialized by this method
**run**
1. Call all systems' initialize first.
2. Call the executor to run program.


## Plugin system
Flow is a plugin that will be loaded dynamically by the Rsim Executor, each flow will be executed serially by the executor by calling the run method in the flow.
- support step command to define a new step of this flow.
	- first defined step will be executed first
	- step require group option, all steps in one group will be displatched at simultaneously.
	- step.action support executing commands, internal procedure or external command.
Call `flow.run` will start execute all defined steps, this will use a RsimJobControl object to dispatch all steps in one group, like: `RsimJobControl.dispatch(steps['group']);RsimJobControl.wait`.
When dispatching one group steps, the main thread will wait for jobs all done.
### RsimFlow
The basic class object derived by all other flow plugins, this object will define some of common or fixed methods and let user objects more easier to create.
### FlowStep
### StepAction


## Job control system
The job control system is the bottom level of threads control system, by which can easily control running jobs both of system commands and internal tool procedures.
The system shall be able to:
1. wait for complete.
2. kill the thread.
3. get exit status while completed.


# Plugins
## Node loading flow: nodeflow
All node commands will be declared within the NodeFlow, so loading nodes shall be within this flow scope, and also, it requires a new object (module DataBase) to store all node information, so the flow shall declare a new object.

**component command**
command used to create a new component object which has compatible information for IP-XACT protocol.

## Build flow: buildflow

## Simulation flow
- [ ] need consider: the name of simulation flow, and how to skip compile while running the flow? maybe the step can also be skipped? such as compile step, sim step?



---
backups
## Multiple thread control
- [ ] what kind of actions can be treated as multiple running threads?
- [ ] how to manage multiple jobs?
1. running simulation can be parallely executing as multiple threads and jobs.
	1. require a config to control the maximum outstanding simulation.
2. building components or running the generator chain can be multiple threads.
	1. no necessary to control the parallel threads, just run in parallel.
both of above actions will call system command to run, the difference is that simultion need have a limit of maximum ongoing jobs.
details refer to:
## Main tool execute procedure
1. tool init
	1. ENV check;
	2. user command line analyze;
2. plugin dynamic loading, based on required steps.
3. 
### plugin dynamic loading

#TBD example in vscode.
plugin features:
1. can be controlled by RsimExe with parallel or serial step.

### building procedure
1. rsim executor call node loader's analyze -> elaborate -> build steps.
	1. build component, design ... xmls
	2. build generators
	3. build compile, elab, run options into target config
2. call generators to build HDL and TB.

# Step
Step concept is used for multiple process control, each step is the least step to execute, such as build a certain component xml, called like: `step.action('componenta.elaborate')`
RsimExe can allocate multiple steps and call in parallel.
#MARKER how to define a step? need consider:
>#TODO, need add management methods, such like ways that can:
		# kill threads by manually.
		# get return information, such as success or failed.

