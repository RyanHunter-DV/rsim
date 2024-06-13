"""
# Object description:
Design, the class used for prcessing the Design object.
# ----------------------------------------------------------------------------------------------
# design.components -> all components instantiated in the design
# ----------------------------------------------------------------------------------------------
"""

class Design < IpXactData

	attr_accessor :instances;
	attr :hierConnect;
	attr :interconnects;

	# 
	attr :adhocs;

	## initialize, 
	# called by global design command, which will build a new Design object
	def initialize(vlnv); ##{{{
		@hierConnects={};@interconnects={};
		@adhocs=[];@instances={};
		super(:design)
		setupNameId(vlnv,:vlnv);
	end ##}}}

	# component instance, before finalize, the instance command
	# only record the vlnv name and the corresponding instance name.
	# and in finalize, the vlnv name will be replaced to real component object.
	def instance(vlnv,**opts)
		raise NodeException.new("no instance specified for component(#{vlnv}) ") unless opts.has_key?(:as);
		vlnv=vlnv.to_s;as=opts[:as].to_sym;
		c=MetaData.find(vlnv,:component);
		raise NodeException.new("no component(#{vlnv}) found in MetaData") unless c;
		#TODO, tmp forget this is for what usage? c.buildComponentInstance(self);
		@instances[as]=c;
		self.define_singleton_method as do
			# return vlnv name of the instance
			return @instances[as];
		end
	end

	# lhs is string based upper level interface name.
	# rhs is object from component instance's interface object.
	def hierConnect(lhs,rhs)
		@hierConnects[lhs]=rhs ;
	end
	def connect(lhs,rhs)
		hierConnect(lhs,rhs) if lhs.is_a?(:String);
		# interface object to object.
		@interconnects[lhs]= rhs;
	end
	def adhoc(**pair)
		pm = PortMap.new();
		pair.each_key do |p,v|
			if p.is_a?(String) ## external port name
				pm.source(lhs,*v);
			else
				pm.target(rhs,*v);
			end
		end
		@adhocs << pm;
	end

	## getInstName(vlnv), according to component's vlnv, return the instname
	def getInstName(vlnv) ##{{{
		@instances.each_pair do |iname,o|
			return iname if o.vlnv==vlnv;
		end
		return '';
	end ##}}}

	def finalize
		# 1. eval user nodes where added when creating.
		evalUserNodes(self);
	end
end


## design(vlnv,&block), 
# command to declare a IP-XACT design
def design(vlnv,&block); ##{{{
	puts "#{__FILE__}:(design(vlnv,&block)) is not ready yet."
	d=Design.new(vlnv);
	d.addUserNode(block);
	MetaData.register(d);
end ##}}}
