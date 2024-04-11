"""
# Object description:
Component, 
Represents the IP-XACT component, created by the global component command, which usually been called
in user nodes.
"""
require 'lib/ipxact/IpXactData.rb'
require 'lib/ipxact/ComponentModel.rb'
class Component < IpXactData ##{{{

	attr_accessor :vlnv;
	attr_accessor :model;
	attr :genConfig;

	## initialize, 
	# the constructor
	def initialize(vlnv); ##{{{
		super(:component);
		@vlnv=vlnv;
		@genConfig={:generator=>nil,:options=>{}};
	end ##}}}

	## -- Supported commands for user nodes ##{{{
	## generator(name), 
	# specify a generator name.
	# block used to declare extra parameters for the generator.
	def generator(name=nil,**opts={}); ##{{{
		#puts "#{__FILE__}:(generator(name)) is not ready yet."
		return @genConfig[:generator] unless name;
		g=MetaData.find(name);
		raise UserNodeException.new("Generator #{name} not defined") unless g;
		if @genConfig[:generator]!=nil
			puts "warning message, TODO"
		end
		@genConfig[:generator]= g;
		@genConfig[:options]=opts unless opts.empty?;
	end ##}}}

	## param(**opts), define parameters for this component
	# if the same component block want to use it, then must defined first.
	def param(**opts); ##{{{
		opts.each_pair do |k,v|
			k=k.to_s;
			#self.instance_variable_set("@#{k}".to_sym,v);
			self.define_singleton_method k.to_sym do |**args|
				return self.instance_variable_get("@#{k}".to_sym) if args.empty?;
				self.instance_variable_set("@#{k}".to_sym,args[0]);
			end
			self.send(k.to_sym,v);
		end
	end ##}}}
	## model(&block), build a new object of ComponentModel type and register it into
	# current component object.
	def model(&block); ##{{{
		m=ComponentModel.new();
		m.instance_eval block; # execute user commands.
		@model=m;
	end ##}}}

	## }}}


	## finalize, to finalize the component according with user specified commands
	def finalize; ##{{{
		puts "#{__FILE__}:(finalize) is not ready yet."
		# 1.eval user nodes
		# 2.if generator is nil, then add a default one: 'link'
		# 3.TODO
	end ##}}}



private

	## -- Internal APIs for object self interactions ##{{{

	## }}}

end ##}}}

## component(vlnv,&block), 
# user nodes to define an IP-XACT component
# format:
# - component 'vendor/library/name/version', do xxx end
def component(vlnv,&block); ##{{{
	puts "#{__FILE__}:(component(vlnv,&block)) is not ready yet."
	c=Component.new(vlnv);
	c.addUserNode(block);
	MetaData.register(c);
end ##}}}