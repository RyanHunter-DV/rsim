require 'lib/ipxact/IpXactData.rb'
class PortType < IpXactData

	attr_accessor :portType;
	attr :parent;
	def initialize(pt=:wire)
		@portType = pt;
		# set datatype
		super(dt: :componentPort);
		@parent=nil;
	end

	# sets the port's parent, means in which this port is defined.
	def parent(o=nil)
		return @parent if o==nil;
		@parent=o;
	end
end
