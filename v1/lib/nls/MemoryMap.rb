"""
# Object description:
MemoryMap, declaring for memory maps, which contains the addressBlocks for registers mainly
# example for memory map using:
map 'name' do
	addressBlock 'name',baseAddress,range,width do
		usage :register
		registerFile 'r.f'
	end
end
map 'map2' do
	addressBlock 'name',... do
		usage :register
		registerFile 'r.f' # in a different map which has different base address, but have same register structure
	end
	submap
end
# in r.f
register 'name',<offset>,<bits> do
	field 'name',<lsb>,<bits>,<access>,<reset>
	...
end
register 'name'...
...
"""
class MemoryMap ##{{{

	## addressBlock(name,base,range,width), declare a new addressBlock object for storing registers in Rsim-g1
	#TODO, require AddressBlock class
	def addressBlock(name,base,range,width); ##{{{
		puts "#{__FILE__}:(addressBlock(name,base,range,width)) is not ready yet."
		#TODO
	end ##}}}
end ##}}}