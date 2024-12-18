"""
# Object description:
ComponentInstance, description
"""
require 'ipxact/Component.rb'
class ComponentInstance < Component ##{{{

	attr_accessor :parent;
	attr :__c__;
	attr :__iname__; # instance name

	## initialize(as,c), 
	# as: instance name
	# c: component object
	def initialize(as,c,p); ##{{{
		#puts "#{__FILE__}:start initialize(as,c) ..."
		super(c.id,:inst=>true)
		@__c__ = c;
		@__iname__= as.to_s;
		@parent=p;
		@__c__.instance(self);
	end ##}}}

	## fullname, return full hierarchical name
	def fullname; ##{{{
		#puts "#{__FILE__}:start fullname ..."
		p=@parent.fullname+'.'+@__iname__;
		return @__iname__;
	end ##}}}

private

end ##}}}