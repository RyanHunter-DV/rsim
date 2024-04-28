require 'lib/ipxact/IpXactData.rb'
class PortMapPair
	attr :logicalPort;
	attr :physicalPort;
	attr :parent;
	def initialize(o)
		@parent=o;
	end
	def logicalPort(*args)
		return @logicalPort if args.empty?;
		@logicalPort={:name =>args[0],:left =>args[1],:right=>args[2]};
	end
	def physicalPort(*args)
		return @physicalPort if args.empty?;
		@physicalPort={:name =>args[0],:left =>args[1],:right=>args[2]};
	end
end
class BusInterfaceType < IpXactData

	attr_accessor :busType;
	attr_accessor :abstractionType;

	attr :endianess;
	attr :bitsInLao;

	attr :portMaps;
	attr :interfaceMode;

	def initialize(n,busT,absT)
		setupNameId(n,:nameGroup); #TODO, need support nameGroup
		@busType=busT;
		@abstractionType=absT;
		@endianess=:little; # by default
		@bitsInLao=8; #default
		@interfaceMode={};
	end

	# user node commands
	def endianess(v);@endianess=v.to_sym;end
	def bitsInLao(v);@bitsInLao=v;end


	def connect(**opts)
		unless opts.has_key?(:logical) and opts.has_key?(:physical);
			raise NodeException.new("connect does not provide logical and physical pair");
		end
		unless opts[:logical].length==3 and opts[:physical].length==3
			raise NodeException.new("connect does not provide correct fields of ports");
		end
		pair=PortMapPair.new(self);
		pair.logicalPort(opts[:logical]);
		pair.physicalPort(opts[:physical]);
		@portMaps<<pair;
	end

	# specify interfaceMode, example format:
	# mode <interfaceMode>,**opts={}
	# mode :master,:addressSpaceRef=>'refname',:base=>0x0
	# mode :slave,:memoryMapRef=>'xxx'
	def mode(m,**opts)
		@interfaceMode[m.to_sym]=opts;
	end

end
