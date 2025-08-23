# object brief description
## simulator exe
this is a executor wrapper called by rsim main tool while users want to execute the eda actions such as compile, run.
## SimApp
The object used to receive the user options for simulation, and according to different `--simulator EDA` to create different bottom layer executor to translate the commands and then call by the executor.
## VcsSimulator
this is the vcs executor, used to translate the unified options from rsim main tool to tool specific options, and do eda specific actions, which will finally create the `<eda>_compile.cmd, <eda>_elab.cmd, <eda>_run.cmd`.
## XceliumSimulator
similar with the VcsSimulator.

# Features & Options description
