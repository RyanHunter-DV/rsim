Rsim-v1 system architecture
# Tool executing steps
1. process user inputs and generate executing commands.
2. load plugins of builtin and from $RSIM_PLUGINS.
3. loading user nodes where the entry is $RSIM_ROOT
4. call to run the plugins.

# Error processing system
The rsim tool supports raising exceptions if user has describe an illegal node, or the tool itself enters an exception state.
Two type of exceptions are now defined:
1. NodeException, for exceptions that caused by user described in nodes.
2. ToolException, for exceptions that caused by unpredicted issues, or internal tool.
*How to process warnings*:
Some of the exceptions are not of critical types, warning message will use Rsim.warning
**Using example**:
Codes if met an issue, directly raise the certain exception with a messae.
---
# multiple threads control system
This chapter describes how the Rsim tool can manipulate multiple jobs parallely.
All jobs that issued by plugins or generators.
**Example sketch**:
```ruby
# in plugin's actions
pids=[]
actions.each do |a|
	if a.isProc
		pids<<dp.emit(a.proc,self)
	else
		pids<<dp.emit(a.cmd)
	end
end
raise "action has error occured" if dp.wait(*pids);
```
## Dispather
This is the main class manager to emit and wait certain threads called by user.
*The emit can only accept the Command object*
`emit(cmd)`:
- if cmd.type is :proc, then use fork with a new procedure block: o.instance_eval &cmd
- if cmd.type is :extern, then build a fork with open.capture3 command to execute the cmd as an external command.
- return pid if pid is not 0.
- if pid is 0, then exit with captured sig or return of instance_eval cmd.
`wait(*ids)`:
- loop the ids, and call Process.wait2(pid), if this not help, then update to more complicated way.
- any of the thread returns abnormal exit will be recorded and return to caller with an int > 0, detailed error information will be reported while executing the sub process.
---
# plugin loading system
Be able to load the builtin and user specified plugins into main tool. Once the plugin has been registered, an internal api from top plugin top system scope can be called.
User commands are prepared by the UserInterface object with a separated string as an array. And can be executed through the top plugin manager's execute API. like: `pluginm.execute(['build.run(:opt=>:value)','compile.run(:opt=>:value)',...]`
## plugin manager
The ==PluginManager== is the top management class object for loading all plugins. All plugins that shall be loaded are specified by users through a ENV variable: $RSIM_PLUGINS. In which defined the files which describes all necesary plugins, mutiple plugins are separated by colon, like: `$RSIM_PLUGINS=‘path1/flow.rh;path2/p/flow.rh’`.
*initialize(userPlugins)*: api to load built-in plugins and user defined plugins from ui.
*execute(commands)*: execute commands from caller, the commands are different flow apis that are defined when loading the plugin system.
## plugin description
This section describes the commands that can be used to build a plugin.
*flow(name,block)*:
flow, a global method to describe a flow plugin. By calling of this command, a ==Plugin== instance will be created and registered into `Rsim.pm`, which is the ==PluginManager== instance.
The given block will be executed after ==Plugin== created, so it let users to declare a series of commands to organize the flow actions.
*api(name,block)*: declare an internal method which can be called by user commands through the plugin manager’s `execute` method. For example, if a flow has defined ‘build’ api while in definition, then calling the plugin manager’s execute method with ‘build’ command can actually invoke the flow’s build api actions.
*step(name,block)*: define different steps for plugin’s run execution. This will create a ==FlowStep== instance within the plugin, which also supports commands in code block.
- after(stepname), indicates the ordering of steps, this step shall be executed after the specified stepname.
- action(name,block), define a step action. By default actions in one step has no ordering requirements so they can be issued to thread controller in parallel.

## loading default generators
This section will decide how to load the default copy and link generator along with the plugin loading system.
Default generators are pre-defined generators that declared by the generator commmands. The generators will be called to run by `MetaData.components.build` in buildflow plugin. Users can specify a different generator within the description of a component, by `generator ‘ref’` command.
`build`:
- api in a ==Component== object.
- call `generator.run(self)`
## generator definition
A global generator command is used to declare a generatorChain, with sub commands specified within that generator block.
`generator(name,&block)`:
- create new object of ==GeneratorChain==
- addUserNode
- register to MetaData, and will be finalized by MetaData.
### generator commands & apis
`exe(s)`:
- specify executor
`action(&block)`:
- describe run actions for this generator, on how to call or execute commands according to current component info.
`run(o)`:
- found blocks stored in generator by calling action.
- execute blocks with given arg of component object, `instance_eval(&block,o)`
- wait all pid that in @pids.
`cmd(*args)`:
- organize the command according to the given args.
- while calling the block in action, each call of cmd will arrange a command using exe+args and issued by the dispather.emit api, and record the pid
- will wait all pid done at the end of run api
## default plugins
### build flow
*buildflow is already built and is fine to use it.*
### compile flow
*completed*
### test flow
*completed*
## basic testing for plugin loading system
- build built-in plugins, like build, compile, runtest.
- setup easy commands and load mechanism to test every steps of the built-in plugins.
- May require dispatcher system, so this relies on dispatcher.
---
# user nodes loading system
Based on IP-XACT protocol, but more ease to describe an object.
The seven top objects are described by calling a global method like global: `component`,`config` …

## testing for nodes loading system
- build a simple project to describe bus, component, design, config basics.
- setup test env to loading nodes.
# user inputs processing system
UI system contains all user inputs containing the options coming with the user command and ENV variables pre-defined by user.
This system will also arrange tool options inferred from internal logics.
## testing for UI
- build test ENV and run the test ENV with support options, just to print if those options are correctly read by UI.

# message report system
To display messages for major two purpose, one is for running tool in normal cases, another is to report debug information in develop mode.
Use verbosity level to control the message. Only the message which has lower verbosity than the given verbo threshold can be displayed.
## test for report system
build in test ENV, display info, warning, error messages. This system can be tested along with other systems who used it.


#project/rsim

