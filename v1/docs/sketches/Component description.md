# Component description
#reference/dv/ipxact/component 

Described for flow tool: [[User commands to describe components]]

- [x] memoryMaps
- [ ] model
- [ ] componentGenerator
- [ ] fielSets
- [ ] choices

## model
element used to define module related information such as views, ports and modelParameters.

- view is an element within model, represents the implementation of a model through different view elements.
	- of ViewType, ref: [[View description]]
	- port is an element to specify the componnt's external ports.
		- of PortType, ref: [[PortType description]]
		- 

collection of following data objects, it shall only have one model in a component:
- views, [[view of component]]
- modelParameters, the modelParameter is used to describe an HDL's model parameters, for language specific, such as the verilog module's parameter.

- [ ] defaultFileBuilder
```xml
<component>
	<model>
		<views>
			<view>
				<name>xxx</name>
				<language>xx</language>
				<moduleName>xxx</modelName>
				<fileSetRef>
					<localName>
				</fileSetRef>	
				<!-- defaultFileBuilder will not used, Rsim will require user to specify the componengGenerator -->
	</model>
</component>
```


- vlnv
busInterface, used to describe a known protocol for a grouped ports of this component, by specifying certain attributes within the busInterface, can easily specify a group of ports that this component used.
More details in [[busInterface description]].

channel, used to describe interconnections between different busInterfaces in a component.
The channel element has only two attributes:
- nameGroup, for name, displayName and description of the channel
- busInterfaceRef, reference for the connected two busInterfaces.

remapState
## memoryMaps
memoryMap is defined for the slave interfaces of a component, used to define the component's local memory space or register space.
*nameGroup*, for identification.
defining internal memory space, or register space.
- [x] addressBlock
*addressBlock*: is of AddressBlockType to specify the following features of register
- name,
- baseAddress
- range
- width
- usage
- volatile
- access
- parameters
- register
- [x] bank
*bank*:
differences between addressBlock:
>The bank element allows multiple addressBlocks, banks, or subspaceMaps to be concatenated together  
horizontally or vertically as a single entity. It contains the following attributes and elements
- bankAlignment:
	- parallel, each item is located at same base address with different bit offsets.
	- serial, each subsequent item located at previous item's address.
- baseAddress: is the base start address of this bank
- addressBlock/bank/subspaceMap: is the containing addressBlock, subspaceMap or nested banks.
- [ ] subspaceMap
The subspaceMap can map the addressSpace in a master interface into a bank.
#question but what's the usage?



Example:
```xml
<memoryMap>
	<name>xxx</name>
```


## addressSpace
addressSpace, specify address space that can be addressed by component's interface, so for a component which has a master interface, then the addressSpace shall specify all available spaces that can be addressed by this component.
*nameGroup*: the id of nameGroup type.
addressUnitBits
*blockSize*:
- blockSize.range specifies the address range of this addressSpace, this is a number of addressable units of the addressSpace, the addressable unit bits shall be defined in addressUnitBits.
- blockSize.width, is the bit width of a row in this addressSpace.
*segments*:
Describe a discrete spaces in current addressSpace, the addressSpace may not all available, so need segments to describe which portions of the addressSpace are available.
- segment.nameGroup
- segment.addressOffset
- segment.range
*executableImage*: specifically for being loaded by a processor's program image.
*parameters*: [[ParameterType description]]

## memoryRemap
Used for a component which has multiple configurations of a memoryMap, such like an RTL that can be write in normal state, but will change to read only in lock state.
#TBD 

## Register
The register description locates in the addressBlock.
```xml
<spirit:register>  
	<spirit:name>status</spirit:name>  
	<spirit:description>Status register</spirit:description>  
	<spirit:addressOffset>0x4</spirit:addressOffset>  
	<spirit:size>32</spirit:size>  
	<spirit:access>read-only</spirit:access>  
	<spirit:field>  
		<spirit:name>dataReady</spirit:name>  
		<spirit:description>Indicates that new data is available in the  receiver holding register</spirit:description>  
		<spirit:bitOffset>0</spirit:bitOffset>  
		<spirit:bitWidth>1</spirit:bitWidth>  
		<spirit:volatile>true</spirit:volatile>  
	</spirit:field>  
</spirit:register>
```


---
backup line
## sub data objects of component
- memoryMaps, bound of [[memoryMap of components|memoryMap]], #question , more details of memoryMap structure?
- [[model of component]], specifies different views, ports and model based parameters of the component.
- 
