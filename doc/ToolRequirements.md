# Major job management
The rsim main tool is the job management tool:
- [ ] based on user inputs, to load required generator chains and execute it.
	- [ ] initflow, tool initialization, help message, version message, log dirs etc.
	- [ ] nodeflow, loading nodes for source information descriptions.
	- [ ] buildflow, used to build files and dirs.
	- [ ] simflow, call eda for compile, simulation etc.
	- [ ] regression flow
- [ ] parallel/serial job management.
	- [ ] different generator chain are called serially
	- [ ] generators in one chain can be parallelly running or serially, according to the phase description.
- [ ] flow and step skip feature
	- [ ] shall be able to skip a generatorChain such like the buildflow.
	- [ ] be able to skip specified steps in a generatorChain.
		- [ ] -s 'build::prebuild,postbuild,...'
		- [ ] -s 'build' -s 'sim::compile'


# build flow
- [ ] build HDL files, details in: [[#build hdl files]]
	- [ ] support building rtl files with component port/bus information.
	- [ ] feature based building.
## build hdl files
Request the build flow to build hdl files from a source which has logical operations in verilog template, and alone with the port/bus information in component node, to generate target standard hdl file.
- [ ] the component command will automatically recognize the name pattern from vlnv, and use the name patter as the module name.
- [ ] user erb file as source hdl files
- [ ] instance logics in a source hdl file shall be coded.
- [ ] ports declaration of a module is omitted, the flow will automatically build according to port description in component nodes.
- [ ] features are located at src/meta/features, described by top command: `feature`, can call with `need` command in config, to setup a certain feature, example:
	- [ ] switch typed feature, if the feature exists, then .., else ...
	- [ ] value typed feature, to set a named feature , according to different values, will generate different rtl file from the template.
	- [ ] local feature and global feature.
		- [ ] local feature declared in a component
		- [ ] global feature uses top 'feature' command.
example: [[component.node]]
#TBD require detailed hdl file examples, use fifo rtl as example.
## build dv files
Following are concepts and ideas that may not achived in G2 version: #TBD 
1. test building mechanism.
	1. test node
2. env building flow.

# simulation flow
This flow will provide common options to organize the eda simulators to compile, elaborate and sim, while also supports manual options.
- [ ] run args from test node
- [ ] compile/elab options from config node
- [ ] reading from built database, to organize the filelist
- [ ] support to skip steps of this flow.

# regression flow
#TODO 

# multiple job control
#TODO 
# message report and logging
#TODO 