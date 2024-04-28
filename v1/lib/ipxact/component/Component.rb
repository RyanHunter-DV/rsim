"""
# Object description:
Component, 
Represents the IP-XACT component, created by the global component command, which usually been called
in user nodes.
"""
class Component < IpXactData

	attr :genConfig;
	attr :memoryMaps;
	attr_accessor :views;
	attr_accessor :ports;

	## initialize, 
	# the constructor
	def initialize(vlnvS); ##{{{
		super(:component);
		#@id=Vlnv.new(vlnvS);
		setupNameId(vlnvS,:vlnv);
		@genConfig={:generator=>nil,:options=>{}};
		@memoryMaps={};
		@views={};@ports=[];
	end ##}}}

	## -- Supported commands for user nodes ##{{{
	## generator(name), 
	# specify a generator name.
	# block used to declare extra parameters for the generator.
	def generator(name=nil,**opts); ##{{{
		#puts "#{__FILE__}:(generator(name)) is not ready yet."
		return @genConfig[:generator] unless name;
		g=MetaData.find(name,:generatorChain);
		raise NodeException.new("Generator #{name} not defined") unless g;
		if @genConfig[:generator]!=nil
			puts "warning message, TODO"
		end
		@genConfig[:generator]= g;
		@genConfig[:options]=opts unless opts.empty?;
	end ##}}}
	def buildDefaultGenerator
		name='link';
		Rsim.info("component(#{vlnv}) has no generator defined, use default(link)",4);
		g=MetaData.find(name,:generatorChain);
		raise ToolException.new("Generator #{name} not defined") unless g;
		@genConfig[:generator]= g;
		#TODO @genConfig[:options]=opts unless opts.empty?;
	end

	## param(**opts), define parameters for this component
	## if the same component block want to use it, then must defined first.
	def param(**opts); ##{{{
		opts.each_pair do |k,v|
			k=k.to_s;
			#self.instance_variable_set("@#{k}".to_sym,v);
			self.define_singleton_method k.to_sym do |*args|
				return self.instance_variable_get("@#{k}".to_sym) if args.empty?;
				self.instance_variable_set("@#{k}".to_sym,args[0]);
			end
			self.send(k.to_sym,v);
		end
	end ##}}}


	# example of trans command
	# trans <name>,<initative> do - end
	# ## uvm_analysis_imp #(ResetGenTrans#(PA),ResetGenMonitor) uimp
	# trans 'uimp', :requires  do
	#	serviceType(typename,typeDefinition,**params)
	# 	serviceType :ResetGenTrans,'ResetGenTrans.svh',:physical => 'PA'
	# 	serviceType :ResetGenMonitor => 'ResetGenMonitor.svh'
	# 	transType :uvm_analysis_imp, 'path/filename'
	# 	connection :max => 1, :min => 1
	# end
	def trans(name,initiative,&block) ##{{{
		#TODO
		p=TransPort.new(name,initiative);
		p.instance_eval &block;
		@ports<< p;
	end ##}}}

	# example of wire command for wire ports
	# wire 'name',:in,:left => int,:right => int # :in, :out, :inout, :phantom
	def wire(name,direction,**opts) ##{{{
		#TODO WirePort.new will set the portType to :wire.
		p=WirePort.new(name,direction,opts);
		p.parent(self);
		@ports<< p;
	end ##}}}


	# example of memoryMaps
	# map 'name' do 
	# 	addressBlock 'name',<baseAddress>,<range>,<width> do
	#		usage :register
	#		access 'read-write'
	#		register 'name',<offset>,<bits>
	# 	end
	# end
	def map(name,&block) ##{{{
		name = name.to_s;
		# 1.create a new MeoryMap object
		m=MemoryMap.new(name);
		# 2.eval block in memoryMap
		m.instance_eval block;
		# 3.set int component's memory maps
		@memoryMaps[name]= m;
	end ##}}}

	# example:
	#busInterface 'busTypeRef','absTypeRef' do
	#	connect :logical=>['name',<left>,<right>],:physical=>['name',<left>,<right>]
	#	bitsInLau 8 # default is 8bit indicates the lowest addressable size.
	#	endianess :little, #default.
	#	mode ...
	#	...
	#end
	#- one component can have multiple busInterfaces.
	#- name element will be automatically built by <component-n_busT-n_absT-n>
	def busInterface(busT,absT,&block) ##{{{
		#TODO, require find to support busDefinition and abstractionDefinition.
		bt = MetaData.find(busT,:busDefinition);
		at = MetaData.find(absT,:abstractionDefinition);
		n=%Q|#{vlnv}_#{bt.vlnv}_#{at.vlnv}|;
		bus=BusInterfaceType.new(n,busT,absT);
		bus.instance_eval block;
		@busInterfaces[n] = bus;
	end ##}}}

	def view(vn,&block) ##{{{
		vn=vn.to_sym;
		v=ViewType.new(vn);
		v.instance_eval block;
		@views[vn]=v;
	end ##}}}

	##}}}


	## finalize, to finalize the component according with user specified commands
	def finalize; ##{{{
		# 1.eval user nodes
		evalUserNodes(self);
		# 2.if generator is nil, then add a default one: 'link'
		buildDefaultGenerator if @genConfig[:generator]==nil;
	end ##}}}



private

	## -- Internal APIs for object self interactions ##{{{

	## }}}

end

## component(vlnv,&block), 
# user nodes to define an IP-XACT component
# format:
# - component 'vendor/library/name/version', do xxx end
def component(vlnv,&block); ##{{{
	c=Component.new(vlnv);
	c.addUserNode(block);
	MetaData.register(c);
end ##}}}
