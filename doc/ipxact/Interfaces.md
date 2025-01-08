
example refs: [[interface]]
# Interface declaration
a bus definition and abstraction definition are used to create interface declarations in global, and components will use the reference name with extra operations to declare a specific interface of that component.
- no elaborate necessary for interface definition.
# Interface connection
This chapter depicts the interface connections, for followings:
- bus connection from component instance to another component instance
- bus connecting with single ports on a component
- bus connecting with mixed single ports and a bus

Usually a connection happens in a design node, by the design command: `connect 'src bus','target bus'` 
## connect from bus to bus
Connecting from bus in a component instance to another bus hierarchy.
while evaling the design node, the src and target bus hierarchical reference will be stored into the Design object.
In finalize design step, while the Config is evaluated, so which components required are already decided, then the connection can be processed.
As shown in example: [[interface#bus connection]]
1. need to find out the busInterface objects of the source and target.
2. the BusInterface need define commands named as the port name.
3. the block given by design's connect method shall be instance_eval in source busInterface object.
4. now only support one port connection.
5. part selection in connect
	1. #TBD 
## connect from port to port
#TODO 
## connect from bus to port
#TODO 

## where the connection will be used?
The port connection mechanism can be used to build a dut instance between tb and dut top.
This can be used as the connectivity flow, which can be a standalone flow after build.
But requires the connect information from the component and design.
Connectivity flow can be used between components, and with a source file, can be used to generate a full standard HDL file.
For example:
```ruby
component 'a' do
	bus 'axi', :as=>'axi0', :master
	port 'logicalPortName', :out, <vector>...
	fileSet 'fs' do
		custom 'inst.vsrc'
	end
end
# inst.vsrc
assign a=b;
always @(posedge iClk ...) begin
	logicalPortName <= 3;
	axi0.awport <= xxx;
end
m2 u2(.awvalid(axi0.awvalid));
# generated.v
module a(axi axi0,output [xxx] logicalPortName);
	assign a=b;
	always @(posedge iClk ...) begin
		logicalPortName <= 3;
		axi0.awport <= xxx;
	end
	m2 u2(.awvalid(axi0.awvalid));
endmodule
```
Only when the component has one single custom file, then can the connectivity flow be used.
Generally speaking, the connectivity flow is declaring the ports described in a component, and encapsulate with the given source file into a standard HDL module file.
Even though the flow can support this, I'm not recommend users to use this feature to connect all modules, since there will be so many component definition for each module and instances in the design.
