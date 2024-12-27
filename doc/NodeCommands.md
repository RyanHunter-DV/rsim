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
#TODO 
# config
#TODO 
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

