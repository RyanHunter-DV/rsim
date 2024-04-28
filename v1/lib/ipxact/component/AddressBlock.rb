class AddressBlock < IpXactData

	attr_accessor :name;
	attr_accessor :baseAddress;
	attr_accessor :size;
	attr_accessor :range;
	attr_accessor :usage;

	attr_accessor :registers;

	def initialize(n,ba,size,range)
		@name=n.to_s;
		@baseAddress=ba;
		@size=size;@range=range;
		@registers={};
	end

	# user node commands
	def usage(u)
		@usage = u;
	end

	def register(rn,offset,size,access,&block)
		r=RegisterType.new(rn,offset,size,access);
		r.instance_eval block;
		@registers[rn.to_s] = r;
	end
end
