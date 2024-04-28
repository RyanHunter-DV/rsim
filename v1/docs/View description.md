# View description
#reference/dv/ipxact/component 

## hierarchical or  non-hierarchical view
- A view can have a hierarchicalRef of a design, by which current view defined as a hierarchical view of this component.
- non-hierarchical view will use the default elements: 'langugae', 'moduleName', 'fileSetRef' ... to specifiy the relative view information.
- [ ] build an example component that to reference an IP design.
*elements for hierarchical view*
==hierarchyRef==: used to specify a design as hierarchical component view.

*elements for non-hierarchical view*
==language==: specify the HDL language, by default is verilog.
==modelName==: specify the HDL model name, for verilog, usually the module name.
==fileSetRef==: name that refer to the defined fileSets in component.

## idea of view in Rsim.
Example sketch, this may changed later:
```ruby
component ...
	view :viewname do
		hierarchyRef 'design vlnv'
	end
	view :non_hier do
		language :verilog
		modelName 'verilog module name'
		fileSet :fileset_name do
			# incdir will be automaticaly set for the path of src file.
			inc 'for include files'
			src 'for source files'
		end
	end
```