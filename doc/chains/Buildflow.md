This page depicts details of the build flow chain.
reference requirements: [[doc/ToolRequirements.md#build flow]]

# elaborating
- build and register all ipxact objects into the Rsim.ipxact class.
- all references shall be elaborated with real registered object

# finalizing
- build database files into out path
	- ruby applied code files in out path, a hash based file that stores different information, such as config, component ...
- finalize the chosen view's fileSet with target files, which are actually used.
- build datafile into target config's out path.

## database files
details in [[doc/ipxact/metadata.md]]
database file is ruby based hash datainfo that can be directly loaded by other ruby based generators by: `instance_eval File.readlines(fn)`
datafile example:
```ruby
{
	:type => :component,
	:id => 'v/l/n/v',
	:node => 'path/.../ndoe.rh',
	:out  => 'path/.../component-instance',
	:generator => 'rtl-builder',
	:ports => ...
	xxx
}
```
In base IpxData class, provides a standard method that can be called by sub classes to record the datainfo, like: `metadata.record(<key>,<value>)`.
By which will record into metadata hash in the IpxData class.
Then in last step of finalize, to call `metadata.write(<path>)` to write data file.



# rtl building
The builtin buildflow will support:
- rtl building by auto port declaration.
- feature based rtl module building.
	- supports component specific feature and global feature
Use a standalone generator, named as rtl-builder, giving options by components, each component can only have one generator invoked, so the source file, component data file will be generated first by rsim, and then call the rtl-builder to execute the building step.
## major steps
1. call `rtl-builder <component-instance> <config path> <target filename>`
2. all component information and features will be automatically load through the component datafile and feature datafile.
3. the target filename shall be considered add to filelist. #TODO
detailed executions are in [[doc/rtl-builder]]

# env building
#TBD, currently not support yet. for env files, currently use 'link' generator

# component generator steps
Despite of the default selected generators, some of the generators will not be selected while they are declared, but will be referenced by component and been selected through components' generator commands.
The chain provides the 'select' command to choose components' generators.
The components' generators are the reference name of Generator after finalize step, calling select will give the name which will be searched through current chain, and stores the options from command.
