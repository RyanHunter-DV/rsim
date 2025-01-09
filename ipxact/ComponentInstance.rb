"""
# Object description:
ComponentInstance, description
"""
require 'ipxact/Component.rb'
class ComponentInstance < Component

	attr_accessor :parent;
	attr :__cn__; # component vlnv
	attr :__c__; # component object
	attr :__iname__; # instance name

	# selected view
	attr :view;

	## initialize(as,c), 
	# as: instance name
	# c: component object
	def initialize(as,cn,p); ##{{{
		#puts "#{__FILE__}:start initialize(as,c) ..."
		super(cn,:inst=>true)
		@__cn__ = cn;
		@__iname__= as.to_s;
		@parent=p;
		@view=nil;
	end ##}}}

	## fullname, return full hierarchical name
	def fullname; ##{{{
		p=@parent.fullname+'.'+@__iname__;
		return @__iname__;
	end ##}}}

	## elaborate, 
	def elaborate; ##{{{
		Rsim.info("elaborating instance of component #{@__cn__}");
		c=Rsim.ipxact.find(@__cn__,:component);
		Rsim.exception(NodeE,:reason=>"cannot find component: #{@__cn__}") unless c;
		c.instance(self);
		@__c__ = c;

		self.views.each do |v|
			# set fileSet objects to all views
			v.link(:fileSet,self);
		end
	end ##}}}
	## finalize, in config's elaborate phase, the component object will
	# be found by config, which will also set the componentInstance's selected view
	# so in component finalize, it will select the selected view's generator into specified chain.
	def finalize ##{{{
		@view.selectGenerator
	end ##}}}
private

end
