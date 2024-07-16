# busInterface description
#reference/dv/ipxact/component 
Used only in a component to describe a bus information for that component.

nameGroup,
busType,
abstractionType,
connectionRequired, boolean type that must specified or not when in integrating.
bitSteering, mark as #TBD  to learn.
endianess,

## bitsInLau
bitsInLau, define the bits of number that are addressable by the least siginificant address bit in interface. By default is 8, which means that the LSB of interface address indicates 8bits of a data.
## interfaceMode
interfaceMode, describes the interface mode in this component, can be any of: master, slave, mirroredMaster, mirroredSlave, system, mirroredSystem and monitor.
*system mode*:
Used for non-standard connection methods, such as connected to an interconnect, or other ways that the mode is not master, slave, montor etc.
Or can be a connection mode for non-standard interfaces deviations from standard bus.
*mirror mode*:
A same or similar ports to its relative bus direct interface mode, has same ports but with reversed directions.
*monitor mode*: mark as #TBD  to learn

## parameter
Of [[ParameterType description]]

## portMap
portMap, connecting information between the abstraction's logical port and component's physical port.
- [ ] why abstraction can define logical port while component has physical port?
One portMap has one logicalPort-physicalPort pair, can define multiple portMaps.
each logicalPort or physicalPort will have name and vector elements to specify the port connecting information.
- The name is of type string
- The vector will have left, right attributes
Example:
```
logicalPort:
	name: xxx
	vector.left: xxx
	vector.right: xxx
physicalPort:
	... # same as logicalPort
```

## busType
- Specify a [[busDefinition concept|busDefinition]] reference indicates the bus type.
- It's mandatory option
