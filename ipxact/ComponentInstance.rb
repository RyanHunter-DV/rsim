"""
# Object description:
ComponentInstance, description
"""
require 'ipxact/Component.rb'
class ComponentInstance < Component

	attr_accessor :parent;
	attr_accessor :outhome;
	attr_accessor :config;
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

		@pool[:fileSet].each_pair do |id,info|
			info[:object].elaborate;
		end
		self.views.each do |v|
			# set fileSet objects to all views
			v.link(:fileSet,self);
		end
	end ##}}}
	## finalize, in config's elaborate phase, the component object will
	# be found by config, which will also set the componentInstance's selected view
	# so in component finalize, it will select the selected view's generator into specified chain.
	def finalize ##{{{
		cn=@id.gsub(/\//,'_');
		@outhome=File.join(@config.outhome,'components',cn+'-'+@__iname__);
		@view.selectGenerator

		_recordData;
	end ##}}}
	## selectView(vn), choose the view object according to the view name, if view name is nil
	# the views shall only have one item, or else will report NodeE.
	def selectView(vn) ##{{{
		vs=views(vn);
		Rsim.exception(NodeE,:reason=>"viewname not given and multiple views found in component(#{@id})") if vn==nil and vs.length >1;
		Rsim.exception(NodeE,:reason=>"invalid viewname(#{vn}) given of component(#{@id})") unless vs;
		@view=vs;
	end ##}}}
private

	## _recordData, record component metadata
	def _recordData ##{{{
		@metadata.record(:node,@root);
		@metadata.record(:outhome,@outhome);
		@metadata.record(:config,@config.id);
		# recording views
		@metadata.record(:views,{});
		views.each do |v|
			#TODO, how to record hierarchical key and values?
			@metadata.record(v.id,
		end


		@metadata.write(@outhome);
	end ##}}}

end
