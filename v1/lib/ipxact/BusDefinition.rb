require 'lib/ipxact/IpXactData.rb'
"""
# Object description:
BusDefinition, object to define the bus interface data
"""
class BusDefinition < IpXactData ##{{{
	
	attr :addressable;
	attr :max;
	## initialize, description
	def initialize(n); ##{{{
		addressable=false;
		@max={:master=>1,:slave=>1}; # default
		vlnv=n.to_s;setupNameId(vlnv,:vlnv);
		super(:busDefinition);
	end ##}}}

	## isAddresable(v), set the addressable field to v
	def isAddresable(v); ##{{{
		@addressable = v;
	end ##}}}

	## maxMasters(num)
	def maxMasters(num); ##{{{
		puts "#{__FILE__}:(maxMasters(num)) is not ready yet."
		@max[:master]=num;
	end ##}}}
	## maxSlaves(num)
	def maxSlaves(num); ##{{{
		puts "#{__FILE__}:(maxSlaves(num)) is not ready yet."
		@max[:slave]=num;
	end ##}}}


	def finalize
		evalUserNodes(self);
	end

end ##}}}
## busDefinition(name,&block), define a new busDefinition by user nodes.
def busDefinition(vlnv,&block); ##{{{
	puts "#{__FILE__}:(busInterface(name,&block)) is not ready yet."
	bs = BusDefinition.new(vlnv);
	bs.addUserNode(block);
	MetaData.register(bs);
end ##}}}

"""
# Object description:
AbstractionDefinition, object represents the abstractionDefinition of IP-XACT
"""
class AbstractionDefinition < IpXactData ##{{{

	attr :busRef;
	# format:
	# ports[:wire] = [];
	# ports[:transactional] = [];
	attr :ports;

	## initialize(n), 
	#
	def initialize(n); ##{{{
		super(:abstractionDefinition);
		@busRef='';
		@ports={};
	end ##}}}

	## bus(vlnv), specify the vlnv of referenced bus
	def bus(vlnv); ##{{{
		puts "#{__FILE__}:(bus(vlnv)) is not ready yet."
		@busRef=vlnv;
	end ##}}}
	## wire(name,&block), declare a wire typed port
	def wire(name,&block); ##{{{
		puts "#{__FILE__}:(wire(name,&block)) is not ready yet."
		p=WirePort.new(name);
		p.addUserNode(block);
		@ports[:wire] << p;
	end ##}}}

end ##}}}

## abstractionDefinition(vlnv,&block), description
def abstractionDefinition(vlnv,&block); ##{{{
	puts "#{__FILE__}:(abstractionDefinition(vlnv,&block)) is not ready yet."
	a = AbstractionDefinition.new(vlnv);
	a.addUserNode(block);
	MetaData.register(a);
end ##}}}
