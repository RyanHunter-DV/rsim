# memoryMap of components
#reference/dv/ipxact/component 
A memoryMap is for defining for a slave interface memory map of a component.

# how to describe the memoryMap in user nodes
#project/infra/rsim/nodes 
I suppose users can declare the register or memory information in a memoryMap in user nodes, which can help generate the RAL model and RTL by build flow.
## map
`map <name>` command, with a specified unique name, used to declare a map, and then along with a code block to describe attributes in the map.

map example:
```ruby
map 'name' do
	# bank
	#subspaeMap
	addressBlock 'name',0x1000,10,32 do
		usage :register
		register 'r0',0x0,32,'read-write' do
			# name,bitOffset,bitWidth,access
			field 'r0_f0',0,4,'read-write' do
				modified :oneToClear # oneToToggle
				# readAction, by default only read if not set.
			end
		end
	end
end
```

## addressBlock
`map::addressBlock` command used to describe a single block.
Command format: `addressBlock <name>,<baseAddress>,<range>,<width> do ... end` 
The do-end block will support addressBlock commands, by calling this addressBlock command, a new AddressBlock object will be create and registered into parent.
`addressBlock::usage`
- memory, for memory type, like ROM, RAM etc.
- register, for register usage
- reserved
`addressBlock::volatile`
`addressBlock::access`
`addressBlock::register`

## bank
`map::bank` command used to describe a collection
using format: `bank <alignment> do ... end`
The do-end block can have multiple addressBlock, bank or subspaceMap definitions, like:
```ruby
bank :parallel do
	addressBlock 'name',0x100 ... # like in memoryMap
end
```
==strategy==: use a module to declare same addressBlock, bank and subspaceMap commands, and then included into map and bank object, so both of which can support same commands in different object scope.
By calling this command, tool will create a MemoryBank object in current object and register it to parent.
## subspaceMap
`map::subspaceMap` not supported yet.