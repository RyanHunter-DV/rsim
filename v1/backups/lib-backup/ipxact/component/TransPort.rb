class TransPort < PortType

	attr :initiative;

	attr_accessor :connections;

	# format array of serviceType, the serviceType is hash which has:
	# :name, :definition, :parameters
	attr :serviceTypes;

	# type definition for this TransPort, for type name and definition location.
	# such as uvm_analysis_port/export, and defined in uvm_tlm...
	attr :transType;

	def initialize(name,init)
		@initiative=init.to_sym;
		@connections={:min=>1,:max=>1};
		@serviceTypes = [];
		@transType={};
	end

	def serviceType(name,define,**params)
		st={:name=>name.to_s,:define=>define.to_s,:params=>{}};
		p={};
		params.each_pair do |t,v|
			# t->type, l->location
			p[t.to_s]=v.to_s;
		end
		st[:params]=p;
		@serviceTypes<< st;
	end
	def connection(**opts)
		@connections[:min] = opts[:min] if opts.has_key?(:min);
		@connections[:max] = opts[:max] if opts.has_key?(:max);
	end
	def transType(name,define)
		@transType[:typeName] = name.to_s;
		@transType[:typeDefinition] = define.to_s;
	end

end
