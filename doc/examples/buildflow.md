A design flow can be represented as a generator chain, which contains an ordered sequences of different tasks.
So the generator chain will be named as the flow command like:
```ruby
flow :buildflow do ##{{{

	# call of generator will do:
	#1.create a new Generator (FlowStep) object and registered into current generatorChain (Flow)
	#2.define a method with the given generator name.
	generator :elaborate do ##{{{
		#TODO, step to elaborating the loaded nodes by calling the DataBase module's elaborate method.
		phase 0.0 # indicates this generator must be executed in serial, need wait  one the job is dispatched
		action do
			DataBase.elaborate;
		end
	end ##}}}
	generator :finalize do
		phase 1.0
		action do
			DataBase.finalize
		end
	end

	# to generate commands for building components
	#TODO
	#step :buildComponents do ##{{{
	#	#1.build component root dir, out[:components] -> out/components
	#	#2.build component instance based on given config.
	#	#2.1.config.needs.each -> o.build TODO, component instance requires build method.
	#	#2.2.build component dir first, out/components/<component name>-<instance name>
	#	#2.3.write the generate command according to given generator.
	#end ##}}}
	generator :link do
		parameter :src => [], :tar => ''
		phase 2.0
		#exe '/bin/ln'
		action '/bin/ln' do
			@src.each do |s|
				basename=File.basename(s);
				t=File.join(@tar,basename)
				command %Q|#{@exec} -s #{s} #{t}|;
			end
		end
	end

end ##}}}
```
# Feature description
- build specified config, and needed components of this config.

## Step: elaborating
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
- Config
	- by elaborating configs, which components are required is now known, then building components will be based on this config.

## Step: finalizing
once all objects are linked with each other, then finalize will be used to overwrite parameters:
- config overwrites component parameters
- generator chain overwrites component generator parameters.
- component interface parameters overwriting.

## Step: buildComponent
1. build common out dirs:
	1. `out[:home],out[:components],out[:configs]`
2. build specific components, build the dirs of all components required by this config.
3. arrange the generator chain.
4. call generator chain with multiple jobs management.
	1. Details in [[#Job control with generator chain]]
5. build ral model by ral flow. #TBD 

## Step: buildConfig


