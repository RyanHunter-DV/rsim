
# Basic IP-XACT diagrams
[[designTop.jpg]]

# IP-XACT features
## design object features
*declare a design with multiple components instantiated*
### interconnections between different component instances

### Declare same component with different instances
There might be a situation that the same component need to be instantiated multiple times so that in the config, these different instances can be set with different parameters.
### Design description referenced by a component
A design object can be referenced by a component with a specific view, thus the component is called an hierarchical component that can make the whole structure hierarchically.
*Example of hierarchical design:*
[[Pasted image 20240604160814.png]]
This feautre usually used to integrate an IP design into subsystem or soc level, so the design may have rtl or verify components, the hierConnect and adhoc connect commands are mainly for connecting RTL components so that the top RTL can be built automatically by the rsim tool.
### Use design nodes to automatically generate a module
A hierarchical component, which has a view that reference a design object can be auto generated its top instance module.
## config object features
### set parameters to a specific component instance
There might be multiple component instance of a same component type, and in those different instances the design configuration will give them parameters that several are the same while others are different.
In DesignConfiguration, it supports to customize the component instances by setting them with different parameters through the command: ==param==, this make users to build different RTL/DV target files from the same component but has different instances. For example, the pcie lanes in two instances will be 4 and 8 respectively, then use:
```ruby
param design.pciea.lane, 4
param design.pcieb.lane, 8
```
above config can tell rsim tool to build two different component instances for this project.
### build different RTL/DV files from same component
An IP-XACT component can generate different RTL/DV files with different component instances and parameters, so the output dir shall be differentiated by the component name format: `components/componentname-instancename`. The componentname is the name of vendor/library/name/version (vlnv) set.

# IP-XACT concept descriptions
## Component
### MemoryMaps
Memory maps described in user nodes are used to create:
- design register description file;
- DV ral model register file;
- DV ral model mem file;

### Ports and interfaces in a component
~~In protocol standard, the component port and interface are used to declare the connection of a component, this can be used to generate a verilog module top in which only has connection information. For example, by giving a file which has only instantiation information, and the component nodes that has model name, single ports and interface declaration, can generate a top module that has multiple instances. In rsim flow, we can build a generator called 'top-gen' to build such kind of modules.~~



# User node commands
Chapter to describe supported commands in user nodes, the first level is top command that can be used directly in a node file.
## command::component
Describe a new component use component and a block to describe how a component is declared: `component 'vlnv' do-end`
### generator
Specify a pre-defined generator to build this component, the name of generator specified in a component must been declared before, or else will report 'generator not found' error.
`generator 'name',options`
- the options is of Hash type, specified by caller as in option=>default_value pairs.
### param
Command to define parameter for this component, once a component parameter is defined, it can be override at config level.
**format**
`param(**opts)`, each opt is specified as parameter name => default value pairs.
For example, to declare a parameter named as 'p0' with default value '10' in a component can be like:
`param :p0 => 10`

### trans
To declare a transactional port of the component. #TODO 
### wire
To declare a wire port of the component. #TODO 
- [ ] what's the usage of a port in a component?
### addressSpace
Declare address space of a component while acting as a master, on how the address spaces it can access.
#TODO , require more typical example of this feature.
### map
Declare the memory map of current component, where a master can send requests to access it. Feature of the MemoryMaps are located in [[#MemoryMaps]]
*Command format*
`map name block`
==name==:
name is a string to specify the name of current map.
==block==:
block is ruby code block in which has sub commands to describe how this map is built. Commands allowed within the map block:
`addressUnitBits value`
command used to specify how many of bits represent once the address incremented, for example value of 8 means each address increment indicates an 8-bit long data.
`addressBlock name,baseAddress,range,width,block`
==name==: string specifier for the declared addressBlock;
==baseAddress==: int type specify the base address of this addressBlock.
==range==: int type with unit specified in map, for example if unit is byte, then range = 10 means this addressBlock has range of 10bytes.
==width==: specify the bit length of each addressBlock line.
==block==: ruby block used to describe this addressBlock
#### addressBlock commands
`usage type`
specify the usage of this address block, symbol or string type, can be: register/mem.
`access type`
specify accessibility, used for mem type only, the register's accessibility shall be specified by register command one by one.
`registerFile filename`
Used to specify a file where defines the register descriptions. The register file must be in the same dir as the component node which declared the registerFile. The file has pure command list to declare register attributes.
Details in here: [[#Register file commands]]

*Command example*
```ruby
map 'name' do
	addressBlock 'name',baseAddress,range,width do
		usage :register
		registerFile 'r.f'
	end
end
map 'map2' do
	addressBlock 'name',... do
		usage :register
		registerFile 'r.f' # in a different map which has different base address, but have same register structure
	end
end
# in r.f
register 'name',<offset>,<bits> do
	field 'name',<lsb>,<bits>,<access>,<reset>
	...
end
register 'name'...
...
```

### busInterface
Specify the interface of the component, can be used along with the port declaration in a certain component.
*Command format*
`busInterface busT,absT,block`
==busT==: a reference name (vlnv) of busDefinition, which must been defined previously.
==absT==: reference of abstractionDefinition.
==block==: sub commands for port connection:
`portMap <logicalPortName> => [left,right], <physicalPortName> => [left,right]`
logical port is the port name defined in abstraction, once the port is mapped, the corresponding connection of another interface will be replaced by the physical port name.
#TODO, will be a future feature.
### view
Command to specify a certain model view of current component. There're two type of view, one is a typical view definition, another is to declare a hierarchical component by referencing the design vlnv.
`view <name> do - end`
command to specify a view type object, which will create a new ViewType object and eval with the given block to define the ViewType object. detailed commands of the ViewType are in [[#ViewType object commands]]
### fileSet
The command to define a fileset for this component, and will be used in different views.
`fileSet <name>,<block>`
This command will create a new FileSetType object and eval the block as in FileSetType object. detailed commands of FileSetType are in [[#FileSetType object commands]]
## command::design
global command to declare a design object.
*Command format*: `design vlnv,**opts,block`
- vlnv, name of design
- opts: specify options with a hash like formats, one of the option is:
	- `:top => true`, specify current design is the top design or not, if this option not specified, by default the design is not a top design, and therefore, the top design can only have one in a project.
- block: sub commands to describe this design
### commands to describe a design
`instance vlnv,opts`
instantiate a component with options, the same component name can be instantiated multiple times with different instance name option.
- `:as => instname`, specify the instance name that can be used by design reference.
`hierConnect lhs,rhs`
Used to connect bus interface between interface in component and interface in design for that component instance.
`adhoc pairs` 
Used to connect single ports between components in current design or components and upper component who encompass current design.

~~**interconnect**
A command to connect inside the design node, mostly used in a top design context that connect RTL top component with the ENV.
Mostly used when connecting a wire typed interfaces or ports with transactional level interfaces.
#Q does this feature useful? can be used to generate tb?~~

## command::config
Create a new DesignConfiguration object and eval the commands through code block given by the command, format:
`config <vlnv>,**opts,<block>`
**options:**
- `:clones => :configname`, clone manual descriptions from other configs, which are list of commands pre-defined before.

### need
setup build list for specific components, only the components that needed by a config will be built to out dir
`need design.componentInstance, :view=>:viewname`
this command specifies a component instance which returns an object of that component instance in the design context, and with a view name, so that in build flow, the corresponding component will be built.
### elabopt
`elabopt *args`, specify elab options for eda tool, args are list of string that used in simulator.
### compopt
`compopt *args`, similar with elabopt.
### design
return current design top context object, use to specify a certain component instance within the design top.

## command::busDefinition
## command::abstractionDefinition

## Register file commands
Command section describe how the registers are declared through a list of commands in the register file.
*register name,offset,bits,block*
starting declare a register by giving its name, offset, and size of bits.
*field name,lsb,bits,access-type,reset-value*
command within the register block, to declare a field of the register

## ViewType object commands

`fileSet <ref>`
specify the fileSets reference, the fileSet shall be defined in the Component object, in view object they will refer to that fileSet in component.
`hierarchyRef <vlnv>`
command to specify the design vlnv id, indicates current view is a hierarchical component that referenced to a pre-defined design object.

## FileSetType object commands
`inc *lists`
Specify include files, which the flow shall build it but not added it into filelist.
`src *lists`
Specify source files that shall be built and added into filelist.



# Examples & usages
[[Rsim-v1 example node descriptions]]

# Report mechanism
The first step of the tool will process UserInterface and then load the reporter, if reporter not ready, use RAW print.
## normal report
Report info/warning called by other components
## error or fatal report
These reported must because of an exception detected, so those report must be called by an exception object.

## Reporter
Class object instantiated in Rsim module, calling of Rsim.info, Rsim.warning ... will actually call the reporter.info, warning ...
**initialize**
constructor with given options
`def initialize(v)`
1. v is the threshold verbosity, all info messages whose verbo larger than the threshold value will be skipped.
	1. `@maxVerbo = v` verbo range is from 0~10 levels, 0 is the highest importance message
2. 
**info**
report message in info severity
`def info(msg,v=5)`
#MARKER 


# Exception process
- Syntax analyzing for user nodes, especifically for illegal usage of node commands.
	- raise NodeException.new(reason,severity)
- invalid setting or configurations when finalizing the metadata.
	- raise NodeException.new(reason,severity)
- invalid user options or tool options
	- raise OptionException.new(reason,severity)
- TBD




# Plugin system description
This section depicts the plugin system, its feature, usage and object descriptions.
The plugin system used by Rsim tool to load different flows and generators for building and running the IC projects.
It support built-in plugins (buildflow, compileflow, testflow etc) and user customized plugins.
The system will be loaded by module Rsim, and all the subsequents are loaded in the top object (class PluginManager) of the plugin system.
Using the plugin system's loading API, the built-in and user custom plugins will be loaded at init phase of Rsim tool.

## plugin loading mechanism
A new plugin will be loaded and defined through the given plugin commands, and loaded through ruby require mechanism to load a ruby file.
Built-in plugin paths are hardcoded in UserInterface once it's been created.
User customized plugin paths are provided by ENV: RSIM_PLUGINS, which are separated by ',', like: `RSIM_PLUGINS='patha/file.rb,pathb/plugin.rb'`
The UserInterface object will process the incoming ENV value, and translated into a list for PluginManager's loading api
## plugin executing mechanism
Declaring command is defined in plugin system, and call the command will create a new object of class Plugin, and registered in PluginManager class.
Calling of plugin command will be given by user options like: `-e 'buildflow(:config=>:Config)'`, this option will be translated as `Rsim.pm.instance_eval :buildflow(:Config)`


### Use flow command to declare a new plugin
A global 'flow' command is used to declare a plugin, and with a code block to customize the flow features.
### defining step of a plugin
#TBD 
A step is of FlowStep class, defined in a Plugin object, used to define a collection of separated actions, the steps has ordering requirements, which means all steps must be executed in serial. While the actions in one step can be executed parallelly.
### defining action in a step
#TBD 

## PluginManager
This is a central class created in Rsim module.
**loading**
API called by Rsim's main step to load user specified plugins and built-in plugins, as described in [[#plugin loading mechanism]].
`def loading(*files)`
1. loop each of files
2. load with ruby kernel require
**register**
API called by the global method: flow, once a new flow is declared, the the plugin object of type: Plugin will be reigstered into PluginManager, a new method will be defined to execute the registered plugin:
`def register(p)`
1. p is the object handler of Plugin to be registered
2. define method, name is the plugin name, option is of Hash type
	1. `define_singleton_method name do |**opts|`
3. call plugin's option setting api, set above method's income opts into plugin's option
4. call plugin's run api, to execute the plugin
**global flow**
defined in the PluginManager.rb file, but is global scope method so that users can declare a new plugin anywhere of the program.
`def flow(name,&block)`
1. search if already registered, if is, then just eval the block of the registered Plugin object
2. if not, then create a new Plugin object.
3. plugin eval the block.
4. call Rsim.pm.register.

---
## Plugin

**options**
API to set options into @option, so that it can be used while user defining the plugin actions.
`def options(opt)`
@option = opt
**run**
API called by registered plugin method
`def run`
2. arrange steps into a new list according to phase, same phase steps are randomly organized.
3. loop arranged steps in current plugin 
4. call step.execute(@dispatcher)
#TBD 
**step**
API called when declaring a new plugin, use to build a FlowStep object, and define the actions.
`def step(name,:phase=>1.0,&block)`
1. if step previously defined, raise user exception
2. create a new FlowStep object, and instance_eval the block.
3. register the step object into @steps, with :phase option:
	1. `@steps << {:step=>FlowStepObj,:phase=>xxx`

[[#defining step of a plugin]], [[#FlowStep]]

---
## FlowStep

**action**
API called when declaring a new plugin, to specify a parallel running action in specific step.
`def action(type,&block)`
1. if type is :proc, then store into @actions << action
	1. `action={:type=>:proc,:exe=>block}`
2. if type is :external, then store into @actions with:
	1. `action={:type=>:external,:exe=>self.instance_eval(&block)`, block will return string typed commands

**execute**
API called by plugin to execute one step, to start all actions parallelly.
`def execute(dp)`
1. dp is from Rsim.dp, which is a dispatcher for multi-thread control.
2. for each @actions, then issue all the actions in parallel
3. wait all actions finished.



