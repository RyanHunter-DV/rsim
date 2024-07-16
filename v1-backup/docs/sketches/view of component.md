# view of component
#reference/dv/ipxact/component 
- Shall be declared within the model of a component.
- Is of ViewType, this type will have sub elements inside.
## elements
- envIdentifier, indicates the hardware environment that this view applies to, format is Language:Tool:VendorSpecific.
- for hierarchical view:
	- hierarchyRef, #question , how to use in project, any example?
		- hierarchical view seems can be used to include an IP design into SOC's component view.
- for non-hierarchical view:
	- language, specify language for this view, like :verilog, :vhdl, :sv ...
	- modelName, language specific name to identify the model while configured to this view. For example, is a verilog module name when in verilog language.
	- defaultFileBuilder, default options to build files by calling the component's generator.
> References an IP-XACT design or configuration document (by VLNV) that provides a design for the component.
- nameGroupNMToken, #question , what's this mean?
- fileSetRef, reference to files defined in component
- constraintSetRef, #question , what's used for?
- whieboxElementRefs, #question , what's used for?
- parameters, additional parameters to describe the view. #question , will this be different with component's parameters?
	- #question how to define different parameters in view and in component?


