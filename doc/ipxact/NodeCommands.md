# component
Thid doc depicts the source node specifications to describe a component, based on Ruby language with provided Rsim built-in commands.
The node descriptions are used to build to standard IP-XACT compatible xml files.
Now supports concepts of:
- VLNV identifier.
- busInterfaces, reference to a pre-defined bus.
- memoryMaps, specify slave memory or register space of this component.
- addressSpace, specify addressable space of the component as a master, usually used by ENV component to config ENV or UVC.
- model, specify views, ports and modelParameters for a parameter.
## bus
reference a pre-defined bus interface.
format `bus <refname> [**options]`
- the reference name is from abstraction definition name.
- options:
	- 'as' => 'name': specify the interface instance name for current component
## wire
specify a wire typed single port.
format `wire <name> <direction> <rsb> <lsb> [**options]`
- name is the port name
- direction will be one of :in/:out/:inout
- rsb, lsb
## fileSet
define a fileSet available in current component, may be referenced by different view.
the specified file maybe not the standard hdl file, so if the file specified as into filelist, then tool need to record its target hdl filename and store to filelist.
#TODO how to specify a corresponding target hdl file and into filelist?
this may achieve in finalize step from build, once all are finalized, then the chosen view's fileSet's target file path shall be recorded.


#TODO 
# design
## instance
Command to instantiate a component data in current design, with given instance name option.
`instance <vlnv>, :as => <instname>`
# config
typical format: `config <vlnv>, <[options => values]> <code block>`
*options*
- clones, config settings can be derivative from other config, now support one parent config only.
## design
specify the design reference, format: `design <vlnv>`
## need
add required component instance from design for current config.
format: `need design.<instance name>, <view>, <[parameters => overwrite value]>`
- view arg is required for this config.
- parameter options can be used to overwrite the component's parameters while calling need.
The need command arg will use direct design instance reference, so the config block may be evaluated after the elaborating done.
## selector
select generators, this used for components which have multiple generators, for components which have only one generator, then its not necessary to call the selector command.
format: `selector design.<instance name>,<generator name>`
## simulator
specify simulator tool, can support xcelium or vcs
format: `simulator <eda name> <code block>`
the code block can contain commands such as compile option, elab options for the specified simulator, like:
```ruby
simulator :vcs, do
	compopt '+define+XXX'
	elabopt '-fsdb'
end
```

# bus
build busDefinition 
format:
```ruby
bus 'vlnv' do
	masters <num>
	slaves <num>
	# TODO, others if necessary.
end
```

# abstraction
build abstractionDefinition, command defined in nodeflow, which will:
1. create a new AbstractionDefinition object instance
2. eval the block, to run the abstraction's node commands.
3. store information into AbstractionDefinition object by calling the node commands.
	1. create wire/trans port objects according to 'wire' command
4. register to DataBase
5. wait for DataBase's elaborate
	1. to find the busDefinition object according to the given bus ref.
```ruby
abstraction 'vlnv' do
	bus '<bus ref>'
	# wire 'logicalName', :onSystem, :isClock, :display => 'optional display name', :width => xxx
	# trans ... 
end
```
## wire
[[Ruby object description#WirePort]]
Uses same ruby class as the component's wire port, but will have different attributes.
supports:
- onSystem, onMaster or onSlave, detail meaning refer to protocol spec.
- isClock, isData or isAddress
- optional lsb, rsb vector given as hash options
- optional display name given as hash options.
## trans
#TBD currently not required
## bus
specify the reference name of busDefinition, will find it in DataBase at elaborate step.
## param
The param command used to declare a parameter for this abstraction, the parameter can be overwritten while in a component or config who references this abstraction.
By which can build the interface file according to the abstraction definition referenced by a component in project.
The parameter will be used as a symbol or string value while setting different abstraction properties, this symbol or string will be replaced to real value after finalizing, the finalize step in node buildflow  is used to overwriting the parameters of each object, for abstraction, to overwrite parameters from a component or config which referenced this abstraction.


example descriptions : [[interface]]


# flow (generatorChain)
The command for defining the generatorChain.
Since a generatorChain can be represented as a design flow, so in current G2 version, the flow means same as the generatorChain.

- [ ] how to embed a user defined generator?
## generator
used to define a new generator here, which is available for current generatorChain only.
calling of this command will build a new Generator object, in which can be a ruby based procedure that runs in main process or a system command called in shell.
### exe
if given args is a string, then will be treated as system command; if is a code block, will treated, will be treated as ruby procedures.
### parameter
used to declare a place holder for executing this generator with exe, by declaring the parameter with a default value, the generator can hold the actions with commands, and while in finalize step, the parameter shall be replaced by real value from configs or components, attention that the value type must be the same.
### precedent
specify generator names that this generator must wait for.
## select
select another chain or a component generator if the specified component has multiple generators.
feature of selecting another generatorChain is currently not supported, #TBD 
use select to pick up required generators in order
examples in [[buildflow]]
