
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


# Examples & usages
[[Rsim-v1 example node descriptions]]


# User node loading system
This chapter depicts the system that to load project nodes (short of NLS) which contains all project required files and parameters so that can be built by different flows.
By collecting descriptions for a project, this tool can help generate required target files, execute commands etc.
## Loading node files hierarchically
The NLS supports loading multiple root nodes by a given env variable: RSIM_ENTRIES, which shall be setup by bootenv before executing the rsim command.
RSIM_ENTRIES can support setting multiple roots through a separator of ':' for loading imported projects and current project, like: `RSIM_ENTRIES=./root:./import/ips/root`
The root node name can be changed by others like `RSIM_ENTRIES=./current_root`, the extension of the root file '.rh' is not necessary to be provided by user.

## Component features & strategies
IP-XACT components are central places for describing a metadata object, by which can be used to:
- generate target RTL modules with a bunch of different parameters set in DesignConfiguration.
- generate target ENV files to test the target RTL modules.
- Combined with component generators to build files required by simulators.
### Component generating mechanism
For each component, there should be a generator used to build the target component, the generator in component is a reference of the pre-defined generator tool. But can have extra options through the generator command. 
One component can only have one generator, that means if a project like rtl/env models of that project has different generate methods, then they shall be decalred as two different components.
Use `generator <name> do-end` to specify which generator this component will use.
The code block will be used to set special actions while running the generator, such as option specification.
### Component parameter mechanism
parameters are declared in component can be set through the DesignConfiguration to build with different set of parameters.
Parameters declared in component with a bunch of commands and a given symbol of the parameter name, such like:
- `param=:name,<value>` command to declare a new parameter in anywhere within the component scope.
- `paramdef?(:name)` return true if parameter defined, or else false.
- `param(:name)` return a declared parameter of current component.
*Use parameter in sub code block*
While in code block description of a sub object, such as fileSet, the parameter shall be also available, example can be like:
```ruby
component do
	fileSet do
		source 'xxx'
		source "*.#{c.param(:ext)}"
	end
end
```
A singleton method of name 'c' will be declared once a sub block is registered into current component, so that calling of c in class scope will refer to the component where the sub-block is registered.

### Component memory map mechanism
The memory map mechanism of a component can be used to generate RAL model for DV usage and the basic reg RTL file for design.
- [ ] future: to support generate uvm_mem and memory descriptions
Currently, the Rsim-g1 tool only supports generating register blocks. So that the memory map can have only addressBlock, which can define register data.
```ruby
memoryMap 'dvtm' do
	addressBlock 'rtla',0xa0000000 do
		register 'name',:bits=>32,:offset => xxx do
			field 'name',:lsb=>0,:bits=>3,:type => :RW,...
		end
	end
	addressBlock 'public',0xb0000... do
		registerFile 'file'
	end

end
memoryMap 'smn' do
	addressBlock 'rtla',0x06000000 do
		registerFile 'file of register, field description'
	end
end
```
For situation that a register block can have multiple different memory map space to access, then users can define memoryMap multiple times with same registers specified by the registerFile.
The registerFile will specify the direct register descriptions same as register definitions in the node file, the file specified will be directly evaled in the addressBlock.

### Component model mechanism
The model mechanism in component used to describe the HDL design information for generating the target component files of RTL.
#TBD 

### Component ports & connections
- [ ] what a component connection defined can be used to?
	- [ ] used to generate top level RTL connection? by giving a source file and connection info, to generate a top component RTL which only has signal connection and module instantiations.
	- [ ] or another way it can be used to generate port connections so that in a source file of the module, there's no necessary to declare a module name and the port connection of a component, only internal logics are required.
Combined with a design build generator, which can support build target verilog module with automatically connections & module name declarations.
- `busInterface <vlnv>, :as => :instname` used within a component to reference a bus definition from global.
- `port ...`, the single port declaration for this component for all views.
- `view <viewname>,xxx`, define a new view in which have fileSet reference and modelName, so that different model can be built by generator. If fileSet is empty, can be used to generate the shell view.
### Building HDL model by component
A HDL model can be automatically built through: interface information, modelName, nested component in IP-XACT, and pure logical description files in verilog syntax.
This requires: [[#Nested component mechanism]] [[#Component model mechanism]]

### Nested component mechanism
Rsim-g1 tool will support the nested component mechanism, which is not described in standard IP-XACT protocol, but can be an enhancement of the protocol, besides, this tool should compliant to the IP-XACT standard protocol.
To support this feature, an extra command shall be added into the component description, by which can add a sub component instance and connected with current component ports.
*Component instance*
instance command in a componentView can be used to instantiate a sub component in current component model, this only supports in verilog syntax and Rsim tool.
Different componentView may have different instantiation and connection description, so this feature shall be all declared within the componentView.
connect shall support:
- connect a sub component instance's single port or bus with current component's single port or port of a bus or bus.
- connect a sub component instance's port or bus to another instance's port or bus or port of a bus.




```ruby
component do
	view 'name' do
		instance 'vlnv',:as => :name0
		instance 'vlnv',:as => :name1
	end
end
```




## Architectural definition of Component
Describe a new component use component and a block to describe how a component is declared: `component 'vlnv' do-end`
### Component class
Object to store a new declared IP-XACT component by the global 'component' command.
**vlnv field**
for idendification
**initialize api**
constructor api
**generator api**
Specify a pre-defined generator to build this component, the name of generator specified in a component must been declared before, or else will report 'generator not found' error.
`generator 'name',*args`
defined in component, this api will record the generator name and args string, once the build api is called by MetaData module in buildflow, then the recorded generator object will be found and executed with the given args string.
The current component object is a built-in arg that will be passed to generator when calling its execute action.
**build api**
Called by MetaData or other internal objects to build target files by the defined generator object.
**param api**
Command api to return the value of defined parameter by giving the param name in symbol type: `param(:name)`
**param= api**
Command api to declare a new parameter for this component, by giving the name and value, the name arg is of symbol type: `param=(:name,value)`
**paramdef?**
Command api to check if the given name has been declared as the component's parameter.
**busInterface api**
used to declare bus interface of this component.
Specify the interface of the component, can be used along with the port declaration in a certain component.
*Command format*
`busInterface busT,absT,block`
==busT==: a reference name (vlnv) of busDefinition, which must been defined previously.
==absT==: reference of abstractionDefinition.
==block==: sub commands for port connection:
`portMap <logicalPortName> => [left,right], <physicalPortName> => [left,right]`
logical port is the port name defined in abstraction, once the port is mapped, the corresponding connection of another interface will be replaced by the physical port name.
#TODO, will be a future feature.
**port api**
declare adHoc ports.
**map api**
declare a memory map for this component
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

**view api**
Command to specify a certain model view of current component. There're two type of view, one is a typical view definition, another is to declare a hierarchical component by referencing the design vlnv.
`view <name> do - end`
command to specify a view type object, which will create a new ViewType object and eval with the given block to define the ViewType object. detailed commands of the ViewType are in [[#ViewType object commands]]
**fileSet api**
The command to define a fileset for this component, and will be used in different views.
`fileSet <name>,<block>`
This command will create a new FileSetType object and eval the block as in FileSetType object. detailed commands of FileSetType are in [[#FileSetType object commands]]

### PortType class
Object for all port types, also ports that decalred within an interface.


## Defining interfaces & abstractions
#TBD 
Section to depict how a nodes been used to declare and generate bus interface and corresponding abstractions.
Abstraction is low level definition of interface, combined with bus definition to declare a full interface descriptions.
BusDefinition used to define a high abstract level of interface.
Interface definition can be used to connect ports between components, by which way can help connecting pure RTL module connections easily.
- [x] Consider to declare a bus interface type in IP-XACT that can suit both for RTL and Verify. no ocnsider
An interface in IP-XACT is now used to connect RTL modules in different scope, through the portMap information that can automatically connect bunch of signal ports automatically, attention this is different with the SV interface. They are simple signal connections in RTL design.
### global command bus
This is a global node command to define a new BusInterface object, this object contains both the IP-XACT BusDefinition contents and AbstractionDefinition contents.
*Commands supported by BusInterface*:
While declaring the BusInterface with the global bus command, sub-commands are supported to customize the BusInterface object, with following commands:
Details can be found in [[#BusInterface class]]
- abstraction, used to declare an abstraction of this bus interface, one bus interface can have multiple abstractions.
abstraction will have commands provided to describe more details, refer to: [[#BusAbstraction class]]
- maxClients, declare the max numbers of devices this bus supported
## Programming object & interactions description
This section depicts objects and their actions in Ruby to achieve above features.
### BusInterface class
**abstraction**
A node command, declared as Ruby method, to describe a new abstraction for current BusDefinition.
`def abstraction(vlnv,&block)`
- vlnv is the name of the abstraction, use string format with: 'vendor/lib/name/version'.
- block is code block been evaled in the newly created AbstractionDefinition class.
1. if vlnv is registered in current object (@abstractions), then raise NodeException with message
	1. multiple definition of same abstraction is not allowed.
2. create new AbstractionDefinition class.
3. instance_eval block.
4. register: @abstractions << AbstractionDefinition object.
**maxClients**
A node command, declared as Ruby method, to describe max masters/slaves
`def maxClients(t,v)`
- t is symbol which indicates the type of client, can be one of: :master,:slave
- v is int value to set max master or slave number
1. set to instance variable: `@maxClients[t.to_sym]=v`

### BusAbstraction class
Class used by command abstraction in a BusInterface class.
*description for customizing an abstraction*:
```ruby
bus xxx do
	abstraction 'vlnv' do
		wire 'xxx' do
			clock # data, address, for qualifier
			# direction option supports :in,:out,:inout
			# width option supports [lhs,rhs]
			# presence => true/false
			onSystem :direction => :in, :width => [0,2]
			onMaster # same option with onSystem
			onSlave # same option with onSystem
		end
	end
end
```

**wire**
Node command to describe a new wire typed port for AbstractionDefinition.
`def wire(name,&block)`
1. create new AbsPort with name.
2. instance eval the block
3. store in to current Abs (@wires << obj)
Detailed wire port commands here: [[#PortType class]]

**trans**
Node command to describe a transactional port.
#TBD 
### ~~AbsPort class~~
~~**initialize**~~
~~constructor.~~
~~`def initialize(name,t)`~~
- ~~t used to specify the @portType of this class, can be :wire or :transactional~~
- ~~name is string of name id.~~
~~**clock**~~
~~command to specify the port qualifier~~
~~`def clock`: @qualifier = :clock.~~
~~**reset**, **data**, similar as **clock**~~
~~**onSystem**~~
~~command to specify wire port options when in system group~~
~~support options:~~
- ~~presence~~
- ~~direction~~
- ~~width~~
~~`def onSystem(**opts)`~~
1. ~~`@groupOptions[:system] = opts`~~
2. ~~#TBD~~ 
~~**onMaster**, **onSlave**, similar with **onSystem**~~



---
backups require re-organized.
## User node commands
Chapter to describe supported commands in user nodes, the first level is top command that can be used directly in a node file.

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


---


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
1. if v > @maxVerbo, then return directly.
2. format message
3. puts formatted message.



# Exception process
Exception system is the only way to exit this program in abnormal way. This system will control how to process different exceptions raised by normal procedures.




```
- User nodes exception process.
	- report message.
	- exit program.
- invalid setting or configurations when finalizing the metadata.
	- raise NodeException.new(reason,severity)
- invalid user options or tool options
	- raise OptionException.new(reason,severity)
```

## NodeException
Class object to process user node exceptions when loading user nodes.
### Exception types and process description
#TBD , details can be found in IP-XACT object definition spec.



# Multi-thread system
This chapter will depict the features, strategeis and architectural objects of the multiple thread control system (short of MTS).
## Supported features of MTS
The MTS is used to dispatch the multiple building commands in parallel threads. For example, while building the components that has no dependencies of different commands, then those commands can be executed in parallel. This sytem only used to receive different commands (supports internal and external two types) and executed it simultaneously and wait for both done.
Besides, the MTS also supports monitoring the command status, the return signal of commands, or timeout monitoring.
### Parallel dispatch
Use 'emit' API provided by this system can directly start a sub thread for a given command. Thus can parallely dispatch multiple commands in main thread through continuously invoking the 'emit' API.
### Timeout monitor
Once multiple times of the 'emit' API is called in main thread, it may require to wait for all sub threads to be completed or timeout. So a timeout process will be started at the main thread, which is also waiting for the sub threads to be completed.
When user calls an API like 'waitall', then a sub thread of `sleep TIME_OUT` will be started, and the main thread will start polling the `emitted` queue of all dispatched jobs' status are FINISHED or the TIMEOUT_FLAG is triggered, any of above status matched, the main thread will report message and start next procedures.
If the TIMEOUT_FLAG matched, then need report timeout message, current still running threads, and then exit with raised exception (MTSE, Multi-Thread System Exception).
### Failed execution process
If all sub threads FINISHED, the exit status shall also been recorded, the MTS only records the exit signal, failed reasons shall be reported by the commands self.
#TBD , can define a signal by literal meaning, like `Signal.trap("HUB") {puts "Ouch"}`
## Architectural description
This section briefly depicts the Ruby objects and interactions between those objects to achieve the features of MTS.
### Dispatcher class
The top class object of the MTS system, which will be initialized at the Rsim module, and apis can be called like: `Rsim.dp.emit...`.
**emit**
Multiple emit can be called at once, each call of this API will start a sub thread with given command.
This API will return the pid of sub thread, for future process.
`def emit(*cmds)`
- support giving multiple commands, execute one by one: cmds.each
- if cmd is internal type
	- create new lambda by `p= -> {}`
		- use cmd.scope.instance_eval cmd.exe
- else if cmd is external type
	- create new lambda by `p= -> {}`
		- create cmd file according to the given path from command: `cmd.scope`
		- execute contents in cmd file through the Shell module
#TBD 
**waitall**
Waiting all current sub threads in the emitted pool, or timeout achieved.
#TBD 
**timeout**
Before the call for waiting all executing threads, a timeout can be set by this API, time unit is second, for example, call of `timeout=60` will set timeout of the dispatcher to be 60 seconds.
**getSignal**
This will start a timeout thread and wait for given pid exit and then return the signal of the exit status, or timeout reached.
### Command class
The ruby class which store the commands to be executed by the dispatcher.
**scope**
For external command, this is the executing path of the command; while for internal command, the scope is an object where the execution will be happened (calling the scope.instance_eval ...)
It can be set through `cmd.scope=...`, or get by `cmd.scope`
**exe**
The execution for command,
- for internal commands, the exe can be a code block of type Proc, or executing string, the dispatcher shall be able to recognize it and doing eval with different code format.
- for external commands, this is the ral command string containing executor and options.


# Plugin system
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





# Main tool execution
## Rsim
The module of a global Rsim tool, called by the rsim executor, by which can init and run the rsim tool.
**Rsim.info**
API to call reporter's formatted print, for debug or normal printing.
**Rsim.run**
API to start Rsim tool
**def self.run**
1. call self.init to initialize the tool information.
2. #TBD 