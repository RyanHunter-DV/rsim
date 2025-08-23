This is the specification for the rsim-g3 main tool, other sub tools such like the builder, simulator etc are located in its self specification docs.
# Overview
# Strategies
## generator chain mechanism
Use global generator command to declare a generator such like build, compile and sim. Those generators will be passed through command line, means the api_type is command line.

users call with '-e' option to pickup specify a simple instruction like: build, compile, or sim, and with certain arguments such as test_name or config name, and option '-s' can be used to arrange different generatorChains, generator developers only need to develop a full chain list, and users can use '-s' option to select required generators to arrange to a certain chain.

for example, here's a chain:

```ruby
chain: simflow
  gen 'build'
  chain_sel 'compile'
  gen 'sim'
chain: compile
  gen 'compile'
  gen 'elab'
```

this is full chain list, and users can use '-s build' to skip the build generator or generator chain, then the target generator.xml will be a chain named simflow to pickup only compile and sim.

'-e' option used to call specific generator chains pre-defined in tool, like: `-e "sim(:testname)"` or `-e "compile(:config)"` 

a chain selected by another chain shall also be able to be skipped by user.

### generator brief

a generator used to depict how a tool will be called, such like compile, elab, sim, build etc, with incoming options set from chain or chain configurations, and generate specific outputs, such like building HDL files.

**commands**

    - exe, specify the path and filename of the executor which will be called when executing.
    - api_type
    - arg
    - more details in code

## filelist building mechanism
## simulator flow mechanism
This section is strategies on how to setup the simulator flow for vcs compile, elab and simulation.
the simulator step been called like a generator, and the different chain used to choose different.
use a generic simulator object to build a unified option calling by the main rsim tool with a unified options, and different simulator executor will be used to translate the unified option into eda specific options.
details in [[simulator-g3_specification]]
# Architecture
