require_relative 'IpxBaseObject'
require_relative 'view'
require_relative 'file_set'

class Component < IpxBaseObject
	attr_accessor :views;
	attr_accessor :file_sets;

	attr :description;
	def initialize(vlnv,p)
		super(p);
		@views = {};
		@file_sets = {};
		@description = "This simple component is created by IP-XACT builder.";
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
	def description(d=nil)
		@description = d if d;
		@description;
	end


	# support user commands:
	# 
	def view(name,&block)
		name = name.to_s;
		v = View.new(name,self)
		v.instance_eval(&block)
		self.views[name] = v;
		NodeApp.info("View #{name} registered to component #{self.name}", 8)
	end
	def fileSet(name,&block)
		name = name.to_s;
		fs = FileSet.new(name, self)
		fs.instance_eval(&block)
		self.file_sets[name] = fs
		NodeApp.info("FileSet #{name} registered to component #{self.name}", 8)
	end
end



