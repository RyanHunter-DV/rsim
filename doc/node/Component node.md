Thid doc depicts the source node specifications to describe a component, based on Ruby language with provided Rsim built-in commands.
The node descriptions are used to build to standard IP-XACT compatible xml files.

Now supports concepts of:
- VLNV identifier.
- busInterfaces, reference to a pre-defined bus.
- memoryMaps, specify slave memory or register space of this component.
- addressSpace, specify addressable space of the component as a master, usually used by ENV component to config ENV or UVC.
- model, specify views, ports and modelParameters for a parameter.