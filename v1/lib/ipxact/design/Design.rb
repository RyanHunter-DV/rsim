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
		puts "#{__FILE__}:(initialize) is not ready yet."
		@hierConnects={};@interconnects={};
		@adhocs=[];
		super(:design)
		setupNameId(vlnv,:vlnv);
	end ##}}}

	# component instance, before finalize, the instance command
	# only record the vlnv name and the corresponding instance name.
	# and in finalize, the vlnv name will be replaced to real component object.
	def instance(vlnv,as)
		vlnv=vlnv.to_s;as=as.to_sym;
		c=MetaData.find(vlnv,:component);
		raise NodeException.new("no component(#{vlnv}) found in MetaData") unless c;
		c.buildComponentInstance(self);
		@instances[as]=c;
		self.define_singleton_method as do
			return @instance[as];
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
