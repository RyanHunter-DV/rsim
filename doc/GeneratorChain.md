- The RsimFlow object indicates the generator chain in IP-XACT
- The FlowStep indicates the generator in IP-XACT
# how's generator chaining executed?
by calling the select command, a series of generators are arranged to be executed, once the chain's execute api is called, then it will start building jobs for each generator actions. Each generator only has one action. The generator can have attribute to wait for precedent generator completed or not.
1. call chain's execute
2. if current generator has precedents, then need wait for precedents done. #TODO 
3. for pure ruby procedures
	1. call generator's execute to instance eval the code block directly
4. for system command
	1. call generator's execute api to return the system command
	2. create a new job object to dispatch the system command.
# build generator command first, then run
executing the generator will first build the generator command file by the action block, so that calling the command api will create a command string line for this generator, and then build into root path.
1. build commands into the command file
2. then call the source command by job control system.

# executing chain flow
1. call generator chain's execute api.
2. get arranged generators, and call generator's execute api.
	1. if generator's execute type is Proc, then use instance_eval in chain scope
	2. if generator's execute type is system, create new Job item, and dispatch it.
		1. the dispatched job item will be recorded into the chain like: `jobs[name]`
		2. if next job has precedence, then need wait, such like: `jobs[<precedent name>].wait`
	3. for system generators, it  need build command first use Proc and then call it with system, so calling the execute of the system typed generator will first build command file, then return the system command.
# picking up component generators
if a component has more than two generators, but in specific config it will only use one specific generator, that shall be specified in config, by ‘select’ node command.
A component can specify different generators for different usage by the group name and options.
For each group, the component generator can reference only one generator, and which will be automatically picked up by config.
For example, calling need will automatically pickup the generator in of 'build' group in component.
```ruby
component ... do
	generator 'ref','build' do
		# parameter overwrite
		args :root => @root,... # called in component

	end

	generator 'ref','compile' do
	end
end
config ... do
	need design.componentInstance
	# build group are 
end
```

## built-in group names
'build' group are for buildflow generator chain.

# generator definition
Users can use the 'generator' command within a generator chain to define a new generator.
## options used by a generator
In most common situations, a generator definition requires parameters from the caller, use a built-in method 'option' to get different options from the caller.
options set while calling the chain's execute, with `**opts` args, and the chain will set all registered generators `__params__`, in generator definition, by calling the `option` method can return the internal `__params__` arg.

# extra generator definition
If users want to declare a new generator, they should reopen the declaration of the generator chain like:
```ruby
flow :buildflow do
	generator 'name' do
		...
	end
end
```

# support defining a command for items using this chain
while declaring a new generator chain, the command method is used to define a new command for any other users to use this generator chain.


# Ruby class description
## Generator
represents as a generator definition, to define the generator.
## GeneratorExecutor
represents a generator executor, which has information of generator definition, and parameters set by a component, by using which can start executing the generator chain since one generator definition may have multiple executors with different parameters, so the GeneratorExecutor is required in program.
