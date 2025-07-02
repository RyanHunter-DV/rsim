class Design < IpxBaseObject
	attr_accessor :description;
	attr_accessor :instances;

	def initialize(vlnv,p)
		super(p);
		@description = "This simple design is created by IP-XACT builder.";
		@instances = {};
		set_vlnv(vlnv.to_s);
	end

	def set_vlnv(vlnv)
		_l=[:vendor,:library,:name,:version];
		parts = vlnv.split('/')
		raise IpxException.new("Invalid VLNV: #{vlnv}") if parts.length != _l.length
		_l.each_with_index do |method_name, index|
			define_singleton_method(method_name) do
				parts[index]
			end
		end
		define_singleton_method(:vlnv) do
			parts.join('/')
		end
	end

	# command used by design node to setup instance with options, for example:
	# instance 'component vlnv',:as=>'inst name'
	def instance(vlnv,opts={})
		raise IpxException.new("as must be specified for instance command") unless opts.has_key?(:as)
		instance_name = opts[:as].to_s;
		opts[:componentRef] = vlnv.to_s;
		@instances[instance_name] = opts;
		self.define_singleton_method(instance_name) do
			return opts[:componentRef]
			#return 'design.'+instance_name;
		end
	end
	def find_component_name(instance_name)
		@instances[instance_name][:componentRef]
	end
end

