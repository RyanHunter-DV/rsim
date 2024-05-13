"""
# Object description:
AbsWirePort, the wire port data type specified in
abstractionDefinition
"""
class AbsWirePort < PortType

	attr :name;
	attr :qualifier;

	# formats is {}
	# [:system] ...
	# [:master]
	# [:slave]
	attr :dir;
	attr :width;
	attr :presence;
	
	## initialize(n), description
	def initialize(n); ##{{{
		@name={};@dir={};@width={};@presence={};
		@name[:logical]=n.to_s; @name[:display] = n.to_s;
		super(:wire);
	end ##}}}
	## display(n), set display name
	def display(n); ##{{{
		@name[:display]=n.to_s;
	end ##}}}
	## isAddress, 
	def isAddress; ##{{{
		@qualifier = :isAddress;
	end ##}}}
	def isClock; ##{{{
		@qualifier = :isClock;
	end ##}}}
	def isReset; ##{{{
		@qualifier = :isReset;
	end ##}}}
	def isData;  ##{{{
		@qualifier = :isData;
	end ##}}}
	## onSystem(dir,**opts), specify behaviors when onSystem
	def onSystem(d,**opts); ##{{{
		@dir[:system] = d.to_sym;
		@width[:system]=opts[:width] if opts.has_key?(:width);
		@presence[:system]=opts[:presence] if opts.has_key?(:presence);
	end ##}}}
	def onMaster(d,**opts); ##{{{
		@dir[:master] = d.to_sym;
		@width[:master]=opts[:width] if opts.has_key?(:width);
		@presence[:master]=opts[:presence] if opts.has_key?(:presence);
	end ##}}}
	def onSlave(d,**opts); ##{{{
		@dir[:slave] = d.to_sym;
		@width[:slave]=opts[:width] if opts.has_key?(:width);
		@presence[:slave]=opts[:presence] if opts.has_key?(:presence);
	end ##}}}
end
