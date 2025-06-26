class Config < IpxBaseObject
	attr_accessor :need_components;
	attr_accessor :description;
	attr :design;
	def initialize(vlnv,p)
		super(p);
		@need_components = {};
		@design={:object=>nil,:name=>''};
		@description = "This simple config is created by IP-XACT builder.";
		set_vlnv(vlnv.to_s);
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
end

#command :config do |name,&block|
def config(name,&block)
	node_path = File.absolute_path(File.dirname(__FILE__))
	c = Config.new(name,node_path);
	# first register to get the design instance, then to call block evaluation
	NodeApp.meta.link_design(c);
	c.instance_eval(&block);
	NodeApp.meta.register('config',c);
end