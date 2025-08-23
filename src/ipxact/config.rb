require_relative 'IpxBaseObject'
class Config < IpxBaseObject
	attr_accessor :need_components;
	attr_accessor :description;
	attr_accessor :compile_options;
	attr_accessor :elaborate_options;
	attr :design;
	def initialize(vlnv,p)
		super(p);
		@need_components = {};
		@design={:object=>nil,:name=>''};
		@description = "This simple config is created by IP-XACT builder.";
		set_vlnv(vlnv.to_s);
		@compile_options = {:vcs=>[],:xcelium=>[]};
		@elaborate_options = {:vcs=>[],:xcelium=>[]};
	end

	def vcs_compile_options(*args)
		@compile_options[:vcs].append(*args) if args;
	end
	def xlm_compile_options(*args)
		@compile_options[:xcelium].append(*args) if args;
	end
	def vcs_elab_options(*args)
		@elaborate_options[:vcs].append(*args) if args;
	end
	def xlm_elab_options(*args)
		@elaborate_options[:xcelium].append(*args) if args;
	end

	def set_vlnv(vlnv)
		_l=[:vendor,:library,:name,:version];
		parts = vlnv.split('/')
		raise IpxException.new("Invalid VLNV: #{vlnv}") if parts.length != _l.length
		_l.each_with_index do |method_name, index|
			self.define_singleton_method(method_name) do
				parts[index]
			end
		end
		define_singleton_method(:vlnv) do
			parts.join('/')
		end
	end


	def designRef(v=nil)
		if v == nil
			return @design[:name];
		else
			@design[:name]= v;
		end
	end
	def design(d=nil)
		if d == nil
			if @design[:object] == nil
				raise IpxException.new("design is nil")
			else
				return @design[:object]
			end
		else
			@design[:object]= d
			@design[:name]= d.vlnv;
		end
	end

	# support user commands:
	# need, to setup a component instance from the design context and which will be built through
	# next building phase actions.
	def need(inst_name,opts={})
		# 1. find component instance from design according to the given instance name.
		#inst = self.design.find_component(inst_name);
		#raise IpxException.new("component instance #{inst_name} not found in design") unless inst;
		# 2. search the opts
		raise IpxException.new("view must be specified for need command") unless opts.has_key?(:as);
		view=opts[:as].to_s;
		@need_components[inst_name.to_s] = view.to_s;
	end
	def needs
		@need_components.keys;
	end

	def find_component_name(instance_name)
		@design[:object].find_component_name(instance_name)
	end
	def find_component_view_name(c)
		@need_components[c.to_s]
	end
end

