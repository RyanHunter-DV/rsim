class AddressBank < IpXactData

	attr_accessor :alignment;
	attr_accessor :baseAddress;

	attr :addressBlocks;
	attr :banks;
	attr :subspaceMaps;

	def initialize(align,base)
		@alignment=align;
		@baseAddress=base;
		@addressBlocks=[];@banks=[];@subspaceMaps=[];
	end


end
