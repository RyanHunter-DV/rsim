# Design description
#reference/dv/ipxact/design 
## elements

### componentInstance
- instanceName, the instance name, unique within this design.
- displayName, for short display.
- description, description for this instance.
- componentRef, ref for component's vlnv.
- configurableElementValue
for component instance configurations, may for component's parameter, or view parameter in that component ...
use referenceId to specify the parameter id, and value is an override item to that parameter.
all parameters are available in component level, by which means a component.view.parameter will be seen as component.parameter, all those parameters are in same scope.
```xml
<spirit:configurableElementValue spirit:referenceId="TPRESC">22</spirit:configurableElementValue>
```

*strategies on Rsim*:
can use instance command on a design to instance the specified component, like:
`instance <component vlnv>, as: :<instance name>`

### interconnections
contains a boundle of ==interconnection== and/or ==monitorInterconnection==.
interconnection, specify the component instance and the bus reference of that component
```xml
<interconnection>
	<name>intc0</name>
	<activeInterface componentRef='inst0',busRef='ibus'/>
	<activeInterface componentRef='inst1',busRef='ibus'/>
</interconnection>
```
**monitorInterconnection**:
Can be used to connect RTL component and DV component.
monitorInterface specify component that behaves as a monitor.
monitoredInterface specify component to be monitored.
```xml
<interconnection>
	<monitorInterface path='xxx',componentRef='xxx',busRef='xx'/>
	<monitoredInterface path='xxx',componentRef='xxx',busRef='xx'/>
</interconnection>
```
>path (optional) defines the hierarchical path of instance names to the design that contains the component instance specified in the componentRef attribute. The path is a slash (/) separated list of  
instance names. If the path attribute is not present, the component referenced by componentRef  
needs to exist in the current design. The path attribute is of type instancePath. See D.5.

**adHocConnection**:
- [x] what's encompassing component?
when the design is integrated to upper level, then it will be treated as a component, the encompassing component means the component whose view referred this design. (hierarchical mechanism)
`<nameGroup>`, specify the connection of this name.
```xml
<!-- connect ports from component instance, to upper level -->
<adHocConnection>
	<name>xx</name>
	<internalPortReference componentRef='xx',portRef='xx',left='xx',right='xx'/>
	<externalPortReference portRef='xx'/>
</adHocConnection>
```

**hierConnection**:
used to connect bus interfaces within this design to upper level when the design is integrated at upper level as a component.
```xml
<hierConnection interfaceRef='xxx'> <!-- interface name that used by upper level when this design is instantiated as a component -->
	<activeInterface componentRef='xxx',busRef='xxx'/>
</hierConnection>
```

*strategies on Rsim*:
Interconnection with a component instance will be declared by a connect command like:
```ruby
design 'vlnv' do
	instance 'comp0-vlnv', as: :inst0
	instance 'comp1-vlnv', as: :inst1

	# bus to bus connection
	connect inst0.bus0 => inst1.bus2

	# hierConnect <encompass component interface> => <instance.interface>
	# if key is a string, then is hierConnect
	connect 'bus ref name' => inst1.bus0

	# adHocConnect
	adhoc inst1.port0 => [<left>,<right>],'extern port name'=>[<left>,<right>]
end
```