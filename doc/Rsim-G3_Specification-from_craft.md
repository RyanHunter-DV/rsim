# Rsim-G3 Specification

This document depicts the Rsim-main shell for job management and all plugin flows for currently used by the simulator executing and verification.

This is the generation third of the Rsim project.

- [x] can be used in daily work for Original project developing.

# Project brief & sketch

## generator chain mechanism


## programming guide for generators

The Rsim-main tool will automatically create a generator chain according to ui, '-e' '-s' options. The generated chain objects will be recorded to the meta database dir, in xml format. and will be executed by the generator executor.

App.run → ui process → node loading → chain executing

## backup sketches

# Rsim-main

The main shell is a simple job management tool.

# Feature description

## Support job dispatching in local or remote.

Local dispatching just dispatch the jobs with multiple threads mechanism.

Remote dispatch currently supports ssh remote command, this feature requires a remote server, which will not be prepared in recent, so it's a reserved feature for now.

### maximun job limit

Users can manually set the maximum parallel job numbers, once the running job number reaches the limit, the main shell will wait for until next slot is available.

## commands supported to describe a custom flow

### action command

command format: `action <name> do-end` 

### ui command

Support plugin options

The plugins may require user options for extra process, so the main shell shall be able to pass user interface actions into different plugins, and shall consider the naming space in case two different plugins uses same options.

command format: `ui <name>,<value>,:desc=><description>`

if the option has no value, then the <value> will be false, the name is the format option like: `-a` .

All user options will be collected to the `@option` of the RsFlow object.



# Strategies

# multiple job management system

The multiple job management system will be named as MultJobSystem, and will be encapsulated as a common lib for future using, so a specification document for this is required: [MJS-G1 Specification](craftdocs://open?blockId=BA6A5EB3-E2E1-4E1B-966B-177FAD83F8EF&spaceId=cacf2afa-0f20-25f2-c6b4-7560532e98b6)

encapsulate each job by a class object, which has types: external command, or internal proc ...

create a JobScheduler static object to manage all encapsulated jobs.

Use the scheduler to dispatch jobs, which may have following steps:

1. schedule step, 
    1. arrange all submitted jobs by different phases.
2. dispatch step, throw the job in to parallel thread, and update the job's status into executing.
    1. executing through phases
        1. in one phase, will first to dispatch all jobs, if reaches the limit, then
            1. to check current ongoing job numbers reaches the limit or not, if reached, then need wait for job retire.
            2. after all jobs finished, then start next phase.
- [x] information required: ruby multiple thread process, shall be able to communicate between main thread and sub thread.

RsJob, is the job class, which will be create every time a new command or job is required to be built, in which has status, and detailed executing context and information.

### job status monitoring

The job status monitoring feature shall mainly to monitor finished or killed by other threads and exit status, so as the exit signal, those status shall be able to be collected by the main shell.

details see: [Job monitoring strategy](craftdocs://open?blockId=20AA2F41-C7D5-4F6D-8A8F-E3CF34B653D3&spaceId=cacf2afa-0f20-25f2-c6b4-7560532e98b6)

### maximum job limit control

### job dispatching phase

jobs scheduled by plugins or other programs will have different phases, multiple jobs in different phases shall be dispatched until above phases' jobs are retired.

Jobs in plugins will be dispatched by calling with a 'action' command, which will be automatically arranged by main shell.



# Object description



log & report mechanism

generator mechanism



# deprecated

# running command - archived

To execute embeded flow actions users can call with '-e <expr>' option, such like '-e simulator(:compile,:pre_compile)'





# embed flow plugins - archived

flow plugins will be created by calling the 'flow' command, which will create a new RsPlugin object and by the ruby's code block mechanism, can declare any other information such like the user options, job actions ...

# Terminology

flow step, one flow can have different named steps, such like compile step, elab step in simflow, the step will not decide the executing ordering.

flow phase, phase is the real value while the lest phase will be executed first, and different phases cannot be executed in parallel.

flow action, is the detailed executing unit.

flow, the flow self has ordering, for example, if user calls simflow, the buildflow is a dependent flow by default, if require skip, then the buildflow will be skipped.

# plugin created and register to main shell

## flow dependecies

while in load_plugins, according to given flow name, to search in PM's flow pool, and read all its predecessors

successor currently not required.

all predecessors defined while declaring that flow.

## strategy to load plugin

- call `RsApp.run` → `app.run` → `ui.parse_command` → `pm.load_plugins` → `pm.setup` →  `pm.run_plugin` 

pm is a `PluginManager` initialized in `Application` while in init.

pm.setup to set configurations before running required flow.



call flow command → create a `RsFlow` object instance, register to `RsApp.plugins`

## strategy to skip steps and/or flows

concept of step and flow, TBD

one flow may have multiple steps, different steps wil have different actions, the phase can be skipped and also the actions, for example, the simulation flow can skip compile step

# register plugin options with ui

plugin options can be registered to the main-shell's RsApp module so that user input command can be used to specify certain options.

The RsApp module is a global naming space for flows to call object APIs such like `RsApp.ui.<xxx>` and other systems like Mjs system.



# strategy to register the flow plugin

1. call the 'flow' command with a code block to define a new plugin.
2. in the code block, can support commands like:
    1. ui, the command to setup a user option
    2. action, jobs can be submitted by the main shell

# commands supported while declaring a new plugin

## ui

ui command used to setup user option supported in main-shell.

So in program executing, step 1 is to get ui parsing and process the main-shell's fixed user options, then second is to load required plugins, third step is to parse the remained user options according to registered user option supported.

## action

action command declares a job action for certain plugin, the job can be internal proc or external commands.

### **specify the action type**

internal proc or external command.

### **specify phase**

the phase is a real timed value, same phase value will be dispatched in parallel, and lower phase value will be dispatched first.

### **specify skip actions**

the actions with 'explict' attribute can be skipped by user like: `-s pre_compile,compile`

# Sketch ideas for flows

### build flow

1. reading source configure files to generate IP-XACT based meta database.
2. generate standard HDL files based on the meta database.

# simulation flow

1. reading standard HDL information from a previous flow
2. call eda simulation steps
3. post process results such as logs and job status if need.

# ui

# actions



collect user specified options, the compile option, elaborate option and run option.

action :pre_compile

user hook action, the api for users to add extra actions before compile.

action :compile





# Architecture

# RsMain

The RsMain file is Ruby language program, is a top file of the tool executor. Which setups up the LOAD_PATH of the directory that this file locates, and requires the 'RsApp'.

create a main method to call the RsApp.run

RsApp

# Rsim-loadflow

# IP-XACT object description

evaluation

The first level node descriptions such like a component, design or config will be evaluated once a node is loaded, but second or higher level blocks still need ordering.

## component

view

specify view of a component, can support multiple views and will be selected while instantiated in a config.

fileSet

declare file collections and use a name that will be linked to view.

memoryMap

TBD

generator

declaring a generator.

### xml format

## design

## config

# generator

mechanism on declaring generator of a component and how to call generators at config.

the global generator command used to declare a new generator.

the componentGeneratorSelector used to choose which generator to be called at certain view.

- [x] need figure out the architectural description of the how generatorChain working mechanism.
  - [x] can reference from deepseek.
  - [x] how to declare a generator, generatorChain and selectors? still declared in node file.
  - [x] but the real executor will be developed in the rsim/g3_00/bins, which are called like executables.
  - [x] how to chain the 'link' generator for every files which requried to be built? may need use the componentGenerator

The Rsim-main and with the plugged buildflow can translate the node files into xml, next will call generator chain to do actions like building rtl, simulation through the generatorChain concepts.



## componentGeneratorSelector

This locates in a component xml, to specify in a certain view, how's the generator parameters can be used of a certain generatorChain.







---

# node_load executor

A standalone executor called by generator chain in main shell, to load project configuration nodes and translated to xml database. Which will be used by next chain or generator like rtl_build, dv_build etc.

\--out xxx, the output base dir

\--entry xxx, add one entry node.



# builder executor

\--builder link/copy/vbuilder, specify using builder, which will start loading from the builders dir which named like: `rtl_<builder name>` 

\--rtl specify to build rtl

\--dv specify to build verifications

currently the rtl builder and dv builder has no difference



# Feature description

support link operation, to link user specified files into target place, different files being passed through the command options, but here's one question, the files may be very large, it's impossible to pass all files through command line, so here's one fix out:

1. to specify the ip-xact meta database, that the builder to read the xml and gets target filesets, then do the building operation.
2. the main tool to create a command list into a certain file, and specified to the builder for simple copy, link or other operations.

choose strategy 1.

the basic builder operation now only need to open the component xml to build all files in the components.

## building strategy from xml

read_config → get component instance and view → call find_component_instance_name

- [x] xml_parser.read_from_file, there's no this method, need build it

# simulator executor

- user options coming from the caller of the generator chain.

**eda specific options:**

```ruby
simulator --vcs_comp_opt '-full64 -debug_access+all ...'
simulator --vcs_elab_opt 'xxxx'
```

simulator options that can be recognized by the sim tool.

- \--vcs, to choose using vcs eda simulator.
- \--out <out_dir>
- \--config_dir <config_name dir>
- \--compile_only, 
- \--sim_only
- \--comp_opt

# collect results from eda

# run multiple testcases in parallel



# executing steps

compile steps

1. build filelist in config path, which given by user option
2. build compile and elaborate command file
3. execute the command file and get exit signal.
4. if not failed, do next sim step.

sim step

1. can called with --sim_only option with a given testsuite and testname option.
2. uvm_testname will be passed as run args.



- [x] need figure out how to pass multiple same options through generator?

---

# Action list

- [x] Rsim-G3 tool be able to support basic ip project

- can support basic ip projects, such as the IP_CPU project in workarea, which has no extra build operations, only need to link and create filelist.
- can support basic vcs compile + sim steps.
- support skip for build or compile.



- [x] need investigate the compile, elab and sim vcs command to actually starting the simulator tool.
- [x] enhance the sub process, the record data and logs shall be in a certain folder.
- [x] change param id like '--config', and value is '${config}'
- [ ] memoryMap features and registerMap for component in the future.
- [ ] require to check critical ENV setting at RsApp.init.
- [ ] build to support xcelium tool.
- [x] build Rsim-main

build the main shell of Rsim flow, by which can load plugin flows and run those flow actions.

- [x] complete flow plugin injection feature

ETA: 10h, 2h*5d

- [x] complete and decide the strategy on loading flow plugins, what to load? and how to load.
- [x] create codes for loading flows, such like calling the flow command, ui command and action command ...
- [x] code to add Mjs system and ui system, which shall be accessed through the RsApp

```ruby
RsApp.ui....
RsApp.mj....
```

- [x] building support for flow
- [x] need figure out how to decide the flow dependencies, for example, how can the plugin manager know the simulation flow requires what kind of flows?


- [x] [MJS] need test for internal command
- [x] build MultJobSystem.await([]), to wait all processes done.


- [x] complete support for buildflow

- [x] support ip-xact based configurations.
- [x] build as simple as possible, by which can setup a sanity IP project first, then start building Original project.
- [x] config xml build, next to build design object and xml database
- [x] then need test the view and component instance xml fields.
- [x] consider generator based on link action, by which can build link target files according to component specified.
- [x] generator chain configuration such like compile options, need consider to solve future.
- [x] complete support for simflow
- [x] enhance current Rsim-main

- [x] support generator and generator chain mechanism.
- [x] in debugging the generator and chain codes.
- [x] the executed generator shall print name and out options, no print of generator command.
- [x] need to enhance the Rsim-main and Rsim-loadflow, the simflow will not be treated as a flow, but a generatorChain.
- [x] the buildflow will be actually a loading flow, just to load node files and publish to xml database.
- [x] next step need to build the node_load program to load ipxact config files into xml database.
- [x] build rtl_build, for now just to support the link operation.

the node_load flow calling by rsim -e build is tested in sanity situation, next to add rtl_build and dv_build to link the target files.

[builder executor](craftdocs://open?blockId=3E0C459A-B263-4ABC-A0CE-7B95A22F22CE&spaceId=cacf2afa-0f20-25f2-c6b4-7560532e98b6)


- [x] build dv_build, for now just to support the link operation.

