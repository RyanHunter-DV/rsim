



# Features and strategies

# Major tool flows
The major tool flow will be:
1. ENV check
2. load plugins
3. loading UI, user options
	1. user option check.
	2. arrange user input commands.
4. load nodes ➝ elaborate
5. build if has
6. compile if has
7. run if has
## ENV check
*   RSIM_ROOT_NODES, all root node files given by bootenv, separate by the colon, like: `./root.rh;./import/ip/root.rh`
*   STEM, the absolute path of current working area. Shall be set before calling this tool.
## Plugin loading flow
1. Main tool will call rhload to load given plugin's entry.
2. The plugin will call Rsim.plugin.register to register and define a method which can be called by user command.
3. execute API of the plugin shall be defined because it will be called if user command has corresponding flow enabled.
Example:
```ruby
buildflow.execute(:config => :Configname)
```

*Builtin flows supported*:
#TODO
- [[BuildFlow-v1 Spec]]
- [[CompileFlow-v1 Spec]]
- [[RuntestFlow-v1 Spec]]

## User nodes loading flow
Use ENV variable to load all root files like: `$RSIM_ROOT_NODE = ./root.rh;./import/tree/root.rh` , node contents will be loaded firstly like:
1. first root in RSIM\_ROOT\_NODE
2. sub nodes included by root above
3. next root in RSIM\_ROOT\_NODE
4. sub nodes included by above root
5. ... recursively
All nodes are placed as global commands that represents the seven top level IP-XACT concepts.
Loading the node files will firstly build the top level structures, such as configs, design, components, interface definition and tests etc. Those structure can be registered first at the MetaData module.
After all nodes are loaded, the next step is to elaborate those definitions. Which will start calling recursive commands within those top scopes. Since the config object will call to set, or override default options, it will be elaborated at the last position. The elaborate order:

1. interface definitions
2. components
3. tests
4. design
5. config

After elaborating, the components or interfaces that are not used by current config will be removed from the internal database.

## Support user defined steps
Users can add specific steps of a loaded flow plugin, and this step can be #MARKER


## Executing build flow
To generate target files from source by the user specified generator and options.
This flow will declare a bunch of APIs that let users to define their own generators, more details are in: [[BuildFlow-v1 Spec]].
The build flow is one of the built-in flow, so it will be loaded every time the rsim tools is started, no way to disable or control the loading configures.
- Rsim.plugin.register, called by this flow to register itself into Rsim module.
- Rsim.buildflow.execute, called by Rsim tool to execute the build flow.
	- `:config => :ConfigName` this option is required by this flow.
	- #TODO , more options may required later.
## Executing compile flow
- Built-in flow.
- Not like build flow, no extension supported.
- Interactive behaviors are same with the build flow.
- Details in [[CompileFlow-v1 Spec]].
- 
## Executing run flow
Running tests with simulator, supports:
- pre-run operations, required for some situations that need build CPP tests before running.
- post-run operations, required for some log process.
## Support step skip


# Architecture
