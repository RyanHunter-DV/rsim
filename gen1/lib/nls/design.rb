"""
# Object description:
Design, the Design object of IP-XACT
"""
require 'lib/nls/IpXactData.rb'
class Design < IpXactData ##{{{

	attr :instances;
	
	## initialize(id), description
	def initialize(id); ##{{{
		super(id);
		@instances={};
	end ##}}}

	## component(name,opts={}), instance a component with given options,
	# :as, instance name specification
	# Instantiate a component will create a reference through design.<instance name>
	def component(name,opts={}); ##{{{
		c=MetaData.find(name,:Component);
		raise NodeE.new("component(#{name}) definition not found") unless c;
		raise NodeE.new(":as option must be specified") unless opts.has_key?(:as);
		as = opts[:as].to_s;
		@instances[as]=c;
		c.instantiatedAs(as); # add one instance name to component,
		Rsim.info("defining method in design:(#{as})",9);
		self.define_singleton_method as.to_sym do
			return c.instanceObject(as);
		end
	end ##}}}
end ##}}}

## design(id), describe a IP-XACT design
def design(id,&block); ##{{{
	c=MetaData.find(id,:Design);
	c=Design.new(id) if c==nil;
	c.addNodes(block.source_location,block);
	MetaData.register(c,:Design);	
end ##}}}