# component node commands and examples
#project/infra/rsim/nodes 
**references**:
- [[PortType description]]
- [[Component description]]

## global component command
#TBD 

## commands within component
### ~~model~~
Although the IP-XACT has a model element to contain ports, views ... elements, it's not required by users since there's only one model wrapper in a component, so users can directly use ports, views commands in a component.
But when translating to XML format, the model shall be added implicitly.

### view
Command to define a view of this component, will create a new [[View type description|View]] type and registered into component.
### wire
Define a wire typed port. Will create a new [[WirePort type description|WirePort]] type and registered into the component pool.
Formats:
```ruby
wire 'name',:in,:left => int,:right => int # :in, :out, :inout, :phantom
WirePort.new(name,direction,:left => xx,:right => xx)
```
by default the left and right are 0, which means are 1-bit long vector.
### trans
Define a transactional typed port. Will create a new [[TransPort type description|TransPort]] type.
Formats:
```ruby
 55      trans <name>,<initative> do - end
 56      ## uvm_analysis_imp #(ResetGenTrans#(PA),ResetGenMonitor) uimp
 57      trans 'uimp', :requires  do
 58        serviceType(typename,typeDefinition,**params)
 59        serviceType :ResetGenTrans,'ResetGenTrans.svh',:physical => 'PA'
 60        serviceType :ResetGenMonitor => 'ResetGenMonitor.svh'
 61        transType :uvm_analysis_imp, 'path/filename'
 62        connection :max => 1, :min => 1
 63      end
```
### modelParam
Define parameters specifically for a design model, that means if the design is of verilog, then this defines the verilog module's parameters.
This definition applies to all views, of type [[ModelParameters type description]]


---
backup line
ref: [[User commands to describe components]]
