# Feature description
- build specified config, and needed components of this config.

## elaborating
Elaborate loaded nodes, for references that are now stored as name will be replaced by real reference object instance.
1. reference of fileSets in a view will be replaced by fileSet objects in the container component.
2. reference of bus interface in a component will be replaced by bus definition object.
elaborate sequence:
1. bus
2. components
3. design, component instances
4. config
*Elaborate node based on ruby classes*
- BusDefinition, nothing to elaborate
- AbstractionDefinition, find bus definition object.
- Component
	- views
		- all fileSets objects be found in container component, with given reference name.
	- generator
		- all source, target files and #TBD , need consider how to collect generator required files.
	- busInterface
		- according to given  abstractiontype name, to find the abstraction definition object, which also contains relative bus definition object.
	- #TODO  more
- Design
	- elaborating component instances, to find and copy the Component objects information, such as port info etc.
		- if necessary, component instance can also store the component object.
	- elaborating connections through the component instances.




---

### Build flow - backup
1. user call rsim with build options, and with given config name.
2. the root.rh must be given in ENV variable at least one root entry is required, multiple root entries are supported by separator ','.
3. loading node files
	1. root node -> required nodes by `rhload` command.
	2. next root node if has ... repeat steps 1.
4. evaluating loaded nodes, build nodes into IP-XACT database, xml formatted files and required scripts and tools.
	1. evaluate designConfiguration by command line.
	2. evaluate design top and interconnection information with configurations in designConfiguration
	3. evaluate required components, added by need command in configuration, with corresponding component parameters.
		1. view configurations
		2. parameter settings
	4. evaluate generator chain, with configs.
5. building nodes into IP-XACT database, xml formatted files and required scripts and tools (optional step)
6. call generator chain to start generating target HDL & DV files according to the built IP-XACT database.
	1. generator chain will also build compile and elab commands for next compiling flow.

## Build flow - backup
The build flow will do elaboration for all loaded node first, and then start building both for files and folders according to specified config.
### Step: elaborate
- [ ] what does elaborate do?

to elaborate loaded nodes:
1. call DataBase.elaborate
2. overwriting configs to available component instance in certain design
3. a config requires elaborate to setting parameters to components, component generators etc  to component instance .
4. elaborate components directly need by config
	1. elaborating nested components, a component may not directly need by config, but indirectly need by a component.
- [ ] add need command in Component, that a component vlnv shall be need by the current component. Attention that the nested component may require the instance component name? or this feature is not necessary, need think again.

### Step: buildComponent
1. build common out dirs:
	1. `out[:home],out[:components],out[:configs]`
2. build specific components, build the dirs of all components required by this config.
3. arrange the generator chain.
4. call generator chain with multiple jobs management.
	1. Details in [[#Job control with generator chain]]
5. build ral model by ral flow. #TBD 

#### Job control with generator chain
After elaborating, the tool will pick up all required generators and build commands into `out/components/<component-inst>/*.exe`, then according to the chain settings, all non-blocking phases can be thrown to job slots, and for blocking phases, after precedent jobs returned, then can those jobs being thrown.
1. in buildComponent step, to create a GeneratorChain object
2. get generator object according to the config's need component instances.
3. arrange generators by giving phases
4. set generators' parameters, such as the source path, out path etc.
5. call generator chain's start action from the minimal phase.
```ruby
chain.build # build commands of each required generator into target path
# *.cmd
#
phases.each do |p|
	pool=[]
	generators.each do |g|
		if g.phase==p
			j=Job.new(%Q|source #{g.path}/#{g.commandName}|);
			j.dispatch;
			pool<<j;
		end
	end
	pool.each do |j|
		j.wait;
	end
end
```
- [ ] How about multiple file building?
for example, a link generator required all source files to be linked to target, then how to get the source files from the component settings? through componentInstance.view.fileSet
#TODO the componentInstance's view attribute is the required view, it is not same as in Component object, in Component object, the view will be all declared views of a component.

### Step: buildInterface
1. the interface definitions.

### Step: buildConfig
1. build config dirs
2. build XML database, not support in current generation.

