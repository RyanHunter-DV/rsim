This page describes about the component concepts for building the IPXACT component, and on flow building for DV/HDL files.
# support generating HDL modules
use a component to describe a HDL module, by a custom generator and source file, can produce a target module file.
this feature can be used for modules which have so many ports that will be not easy to declare signals.
# support building with multiple HDL modules
the component also supports to describe standard HDL modules by giving the fileSets. A bunch of HDL files can be encapsulated as a ipxact component and instantiated into the ipxact design.
# specifying file sets
- use v command to specify verilog source
- use sv command to specify the sv or svh source files.
- use vs command to specify custom source files.
- by default all shall be in filelist
- root command to specify a root path for all files.
# specifying view
use view command with a code block to describe a new view definition.
# describing bus or ports
The component now supports bus and wire ports that used to generate the target HDL files.
# support register description
The register description shall be able to generate register RTL or RAL model by the giving data information.
# local objects will be created once the command called
object locates in component local such as the port declaration, view and fileSets will create corresponding objects and registered in component.



---
```backup

# building register HDL modules
by giving the register descriptions, can help generate the register module based on different bus interface.
#TBD not ready for G2 version.

```
