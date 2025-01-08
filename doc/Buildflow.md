This page depicts details of the build flow chain.
reference requirements: [[doc/ToolRequirements.md#build flow]]

# elaborating

# finalizing
- build database files into out path
	- ruby applied code files in out path, a hash based file that stores different information, such as config, component ...
- finalize the chosen view's fileSet with target files, which are actually used.

## database files
database file is ruby based hash datainfo that can be directly loaded by other ruby based generators by: `instance_eval File.readlines(fn)`
datafile example:
```ruby
{
	:ipxact => :component,
	:id => 'v/l/n/v',
	:node => 'path/.../ndoe.rh',
	:out  => 'path/.../component-instance',
	:generator => 'rtl-builder',
	:ports => ...
	xxx
}
```

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
