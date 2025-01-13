The metadata is ipxact compatible information that can be translated to different codes with a unified format.
Following now specifies the format in ruby code.
# type
This is the very common keyword to distinguish different object attributes, the type is of the object type, which will be:
- component
- design
- config
- busDefinition
- abstraction
- view
- port
- generator
- chain
- 

the data format will be like:
```ruby
{
	:type => <the top type>,
	<other keys based on different type>
}
```
# component type
data format of component type will be:
```ruby
{
	:type => :component,
	:vlnv => 'v/l/n/v',
	:node => 'the source node file described this component',
	:outhome=>'out home path',
	:views => {
		# all declared views
		'view name' => {
			:fileSet => 'file set reference name',
			:generator => {
				:name => xxx,
				:options => {xxx}
			}
		},
		...
	},
	:fileSets => {
		# all declared filesets
		'file set name' => {
			:verilog => {
				:incs => [xxx],
				:srcs => [xxx]
			},
			:sv => {xxx} # similar with above
			:vs => {
				:incs => [xxx], # include path ?
				'src file name' => 'target file name',
				...
			} 
		},
		...
	},
	:selectView => 'the selected view name',
	:ports => {
		# list of single ports
	},
	:buses => [
		# reference name of buses declared in here
	]
}
```

# design type
```ruby
{
	:type => :design,
	:vlnv => 'xxx',
	:outhome=>'xxx',
	:instances => {
		'instance name' => 'component vlnv'
		...
	}
}
```

# config type
```ruby
{
	:type => :config,
	:vlnv => 'xxx',
	:node => 'xxx',
	:outhome => 'xxx",
	:design => 'design vlnv',
	:needs => {
		'instance name' => 'component vlnv',
		...
	}
}
```

# Architecture on metadata program
This chapter depicts how to develop the rsim tool to support recording and writing metadata.
1. record hierarchically
2. write the data directly, since the data is used by program, so it's not necessary to make data readable.
## record hierarchically
Every ipxact object will have a metadata class instance which will be called by the object to record data like: `metadata.record(key,value,parent)`, it supports only one depth of keys. and call method of `metadata` will return the hash which stores current object.
#MARKER
