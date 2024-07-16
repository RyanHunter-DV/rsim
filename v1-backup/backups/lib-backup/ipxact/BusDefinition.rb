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

	## isAddressable(v), set the addressable field to v
	def isAddressable(v); ##{{{
		@addressable = v;
	end ##}}}

	## maxMasters(num)
	def maxMasters(num); ##{{{
		@max[:master]=num;
	end ##}}}
	## maxSlaves(num)
	def maxSlaves(num); ##{{{
		@max[:slave]=num;
	end ##}}}
	## maxClients(**opts), specify maximum masters,slaves or other devices
	def maxClients(**opts) ##{{{
		opts.each_pair do |k,n|
			m="max#{k.capitalize}s".to_sym;
			self.send(m,n);
		end
	end ##}}}

	## directConnection(v), set true/false indicate the bus supports
	# direct connection or not
	def directConnection(v) ##{{{
		# TODO, currently not supported yet
	end ##}}}

	def finalize
		evalUserNodes(self);
	end

end ##}}}
## busDefinition(name,&block), define a new busDefinition by user nodes.
def busDefinition(vlnv,&block); ##{{{
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
		@busRef='';
		@ports={};
		vlnv=n.to_s;setupNameId(vlnv,:vlnv);
		super(:abstractionDefinition);
	end ##}}}

	## bus(vlnv), specify the vlnv of referenced bus
	def bus(vlnv); ##{{{
		@busRef=vlnv;
	end ##}}}
	## wire(name,q,&block), declare a wire typed port
	# q-> specify the qualifier of the wire, can be :isClock, :isReset...
	def wire(name,q,&block); ##{{{
		#puts "#{__FILE__}:(wire(name,&block)) is not ready yet."
		p=AbsWirePort.new(name);
		p.send(q.to_sym);
		p.addUserNode(block);
		@ports[:wire] << p;
	end ##}}}

	## finalize, do finalize of loading nodes process
	def finalize ##{{{
		evalUserNodes(self);
	end ##}}}
end ##}}}

## abstractionDefinition(vlnv,&block), description
def abstractionDefinition(vlnv,&block); ##{{{
	puts "#{__FILE__}:(abstractionDefinition(vlnv,&block)) is not ready yet."
	a = AbstractionDefinition.new(vlnv);
	a.addUserNode(block);
	MetaData.register(a);
end ##}}}
