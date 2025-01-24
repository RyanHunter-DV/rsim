This page is specification of customized rtl building tool. A generator will be build in the rsim's buildflow, by sending the 'rtl-builder' command.
# Feature description
- support feature based rtl building
	- the feature file will be built by the rsim flow, in ruby format.
- command format:
	- `rtl-builder <component target path> <target filename> <source filename>`

## The feature concept used by component node
for example, to declare the port width in a component node, which will require the feature key to be the placeholder.
That requires the feature node to be loaded and linked to component at elaborate phase, and in port or bus elaborate action, to update the place holder of the feature key with real feature value.


# Sketches

```
// *.vsrc file
always @(posedge iClk or negedge iRstn) begin

	// need show the apb busies display name of a certain port, or use a unified naming rule, such like: PSEL.
	// the suffix is used for multiple bus in one module.
	psel<suffix> <= xxx 
end
```

