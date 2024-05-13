# PortType description
#reference/dv/ipxact/component 
## what and how ports used in component?
- name
- [ ] access, why this is need and how accessType and accessHandle means?

*wire port*:
to specify a vector like port, this mostly used in RTL components.
- allLogicalDirectionsAllowed defines the port maybe mapped to a port in abstractionDefine with a different direction, default is false.
- direction: in/out/inout/phantom.
	- phantom used to define a port only exists in IP-XACT concepts.
- vector, specify the left and right bits of this port.
- #TBD others are not necessary for now.
### transactional port
the transactional ports are used mostly between DV components, can be used to connect TLMs in different ENV.
1. *transTypeDef, has sub elements*:
typeName, specify the name of the port type
typeDefinition, specify the file that actually defined the port type
examples:
```xml
<transTypeDef>
	<typeName>uvm_analysis_port</typeName>
	<typeDefinition>uvm_tlms.svh</typeDefinition>
</transTypeDef>
```

2. *service*, defines the protocol associated with the port.
**initiative**, defines the port access is requires, provides, both or phantom, for example, a uvm_analysis_port is of type provides. export is of type both ...
**serviceTypeDef**, in UVM ports, mostly used to define the ports' transaction types.
==typeName==, indicates the protocol type of the port
==typeDefinition==, the location of the type defined.
==parameter==, specify the parameter of the protocol if has.
example:
```xml
<service>
	<initiative>provides</initiative>
	<serviceTypeDef>
		<typeName>uvm_sequence_item</typeName>
		<typeDefinition>uvm_seq.svh</typeDefinition>
		<parameters>
			<parameter name="addr">ADDR</parameter>
		</parameters>
	</serviceTypeDef>
</service>
<!-- the service is within the model with specified language, such as SV, so this service part can be translated to SV language based file by builder -->
```

3. connection
for SV language, used to specify a UVM TLM's connection limits.
==maxConnections==, non-negative number
==minConnections==, non-negative number


---
backup
A component supports multiple ports, which is bound of [[PortType description]].
nameGroupPort, is a group of names for defining a PortType id.
- name, for the port name, is of [[PortName type]].
- displayName, string type.
- description, brief description of this port.
wire/transactional, specify this port is wire type or transactional type.
- wire port is of [[WirePort type description]].
- transactional, #question details, since not used this type yet?
- 
