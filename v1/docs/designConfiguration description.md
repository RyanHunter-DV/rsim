# designConfiguration description
#reference/dv/ipxact/design 
#project/infra/rsim/nodes 

## designRef
generatorChainConfiguration
interconnectionConfiguration
viewConfiguration


## strategies on Rsim
*config inheritance*: #TBD 
*configurable generatorChain*:
- need, use need command to specify which component to be built by generatorChain.
- compopt, used to specify the compile flow chain parameters.
- elabopt, also used for compile flow chain, of the elaboration step.
*design reference*: 
- design, command to specify design ref.
*select instance views*:
- view can be set while calling the need commands.
*Examples*:
```ruby
config 'vlnv config name',:clones => 'vlnv' do
	design 'vlnv'

	need design.inst0 => :viewname,design.inst2 => :viewname
	need ... => ...

	compopt '-a value','',...
	elabopt '+define+xxxx','xxx',...

	# generatorChain built shall be registered on config to set extra options.
	buildflow <param name> => <override value>

end
```