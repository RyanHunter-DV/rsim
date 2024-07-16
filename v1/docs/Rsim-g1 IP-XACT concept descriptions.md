
## Component
### MemoryMaps
Memory maps described in user nodes are used to create:
- design register description file;
- DV ral model register file;
- DV ral model mem file;

### Ports and interfaces in a component
~~In protocol standard, the component port and interface are used to declare the connection of a component, this can be used to generate a verilog module top in which only has connection information. For example, by giving a file which has only instantiation information, and the component nodes that has model name, single ports and interface declaration, can generate a top module that has multiple instances. In rsim flow, we can build a generator called 'top-gen' to build such kind of modules.~~