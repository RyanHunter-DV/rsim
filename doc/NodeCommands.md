# component
Thid doc depicts the source node specifications to describe a component, based on Ruby language with provided Rsim built-in commands.
The node descriptions are used to build to standard IP-XACT compatible xml files.

Now supports concepts of:
- VLNV identifier.
- busInterfaces, reference to a pre-defined bus.
- memoryMaps, specify slave memory or register space of this component.
- addressSpace, specify addressable space of the component as a master, usually used by ENV component to config ENV or UVC.
- model, specify views, ports and modelParameters for a parameter.

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
build abstractionDefinition
```ruby
abstraction 'vlnv' do
	bus '<bus ref>'
	# wire 'logicalName', :onSystem, :isClock, :display => 'optional display name', :lsb=>xx,:rsb=>xxx
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

