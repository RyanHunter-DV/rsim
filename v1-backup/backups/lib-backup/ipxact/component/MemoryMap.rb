require 'lib/ipxact/IpXactData.rb'
require 'lib/ipxact/component/AddressBlock.rb'
require 'lib/ipxact/component/MemoryMapCommands.rb'
class MemoryMap < IpXactData

	attr_accessor :name;

	attr :addressBlocks;
	attr :banks;
	attr :subspaceMaps;

	def initialize(n)
		@name=n;
		@addressBlocks=[];@banks=[];@subspaceMaps=[];
	end

	## user node commands
	include MemoryMapCommands;

end
