- The RsimFlow object indicates the generator chain in IP-XACT
- The FlowStep indicates the generator in IP-XACT
# how's generator chaining executed?
by calling the select command, a series of generators are arranged to be executed, once the chain's execute api is called, then it will start building jobs for each generator actions. Each generator only has one action. The generator can have attribute to wait for precedent generator completed or not.
1. call chain's execute
2. if current generator has precedents, then need wait for precedents done. #TODO 
3. for pure ruby procedures
	1. call generator's execute to instance eval the code block directly
4. for system command
	1. call generator's execute api to return the system command
	2. create a new job object to dispatch the system command.
# build generator command first, then run
executing the generator will first build the generator command file by the action block, so that calling the command api will create a command string line for this generator, and then build into root path.
1. build commands into the command file
2. then call the source command by job control system.
