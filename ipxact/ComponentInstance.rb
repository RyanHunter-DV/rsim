"""
# Object description:
ComponentInstance, description
"""
require 'ipxact/Component.rb'
class ComponentInstance < Component ##{{{

	attr_accessor :parent;
	attr :__cn__; # component vlnv
	attr :__c__; # component object
	attr :__iname__; # instance name

	## initialize(as,c), 
	# as: instance name
	# c: component object
	def initialize(as,cn,p); ##{{{
		#puts "#{__FILE__}:start initialize(as,c) ..."
		super(cn,:inst=>true)
		@__cn__ = cn;
		@__iname__= as.to_s;
		@parent=p;
		#@__c__.instance(self);
	end ##}}}

	## fullname, return full hierarchical name
	def fullname; ##{{{
		#puts "#{__FILE__}:start fullname ..."
		p=@parent.fullname+'.'+@__iname__;
		return @__iname__;
	end ##}}}

	## elaborate, 
	def elaborate; ##{{{
		Rsim.info("elaborating instance of component #{@__cn__}");
		c=DataBase.find(@__cn__,:component);
		Rsim.exception(NodeE,:reason=>"cannot find component: #{@__cn__}") unless c;
		c.instance(self);
		@__c__ = c;
	end ##}}}
private

end ##}}}