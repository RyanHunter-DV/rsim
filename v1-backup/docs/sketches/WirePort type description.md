# WirePort type description
#reference/dv/ipxact/datatype
#project/infra/rsim 

Class derived from [[PortType description|PortType]] class, which has common features both for WirePort and TransPort
## commands supported in user nodes
When declaring a wire port with `wire` command in a component, the port will be created and registered into that component.

## Attributes
direction, protocol supports: in, out, inout and phantom.
- phantom means the port only exists in IP-XACT description.
vector, specify the vector by left and right sub elements.
