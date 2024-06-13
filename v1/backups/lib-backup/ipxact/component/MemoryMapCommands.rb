module MemoryMapCommands
	def addressBlock(n,ba,size,range,&block)
		ab=AddressBlock.new(n,ba,size,range);
		ab.instance_eval(block);
		self.addressBlocks<< ab;
	end

	def bank(align,base,&block)
		ab=AddressBank.new(align,base);
		ab.instance_eval block;
		self.banks<< ab;
	end
	#TODO, subspaceMap command not supported yet.
end
class AddressBank
	include MemoryMapCommands;
end
