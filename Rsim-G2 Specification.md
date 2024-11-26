# Feature description

- Easy for functional simulation.
	- Building the standard HDL (verilog) and TB (systemverilog + cpp) files.
	- Compiling the standard HDL+TB files, with user given extra options.
	- Simulation with compiled database with user given extra options.
- Regression and report collection.
	- #TBD , covreage report, tag based regression
- Based on IP-XACT protocol.
- compatible with XML format database.

# Building
The building flow, means all building mechanism from a manual specified source format files into standard, EDA supported HDL and TB files.
Rsim tool generically declare a common API that let third party plugins can be invoked and generated to target files and places.
