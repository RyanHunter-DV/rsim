"""
# Object description:
Component, 
Represents the IP-XACT component, created by the global component command, which usually been called
in user nodes.
"""
class Component < IpXactData

	attr :genConfig;
	attr :memoryMaps;
	attr :defaultView;
	attr_accessor :views;
	attr_accessor :ports;
	attr_accessor :outhome;

	attr :parameters;

	## initialize, 
	# the constructor
	def initialize(vlnvS); ##{{{
		super(:component);
		#@id=Vlnv.new(vlnvS);
		setupNameId(vlnvS,:vlnv);
		@genConfig={:generator=>nil,:options=>{}};
		@memoryMaps={};@defaultView=nil;
		@views={};@ports=[];
		@parameters={};
	end ##}}}

	## -- Supported commands for user nodes ##{{{
	## generator(name), 
	# specify a generator name.
	# block used to declare extra parameters for the generator.
	def generator(name=nil,**opts); ##{{{
		#puts "#{__FILE__}:(generator(name)) is not ready yet."
		return @genConfig[:generator] unless name;
		if @genConfig[:generator]!=nil
			puts "warning message, TODO"
		end
		@genConfig[:generator]= name;
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

	## param(n), return the defined parameter value by given name in symbol format
	def param(n); ##{{{
		n=n.to_sym;
		raise NodeException.new("param(#{n}) of component(#{vlnv}) been used before declared") unless @parameters.has_key?(n);
		return @parameters[n];
	end ##}}}
	## param=(n,v), declare a new parameter with default value
	def param=(n,v); ##{{{
		n=n.to_sym;
		@parameters[n]= v;
	end ##}}}
	## paramdef?(n), return true if has param named as n, or else return false
	def paramdef?(n); ##{{{
		n=n.to_sym;
		return true if @parameters.has_key?(n);
		return false;
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
	#TODO, to be deleted,def trans(name,initiative,&block) ##{{{
	#TODO, to be deleted,	#TODO
	#TODO, to be deleted,	p=TransPort.new(name,initiative);
	#TODO, to be deleted,	p.instance_eval &block;
	#TODO, to be deleted,	@ports<< p;
	#TODO, to be deleted,end ##}}}

	# example of wire command for wire ports
	# wire 'name',:in,:width=>[msb,lsb] # :in, :out, :inout, :phantom
	def port(name,direction,t=:wire,**opts) ##{{{
		#TODO WirePort.new will set the portType to :wire.
		p=PortType.new(name,t);
		# set attributes for default group, which is for a single port.
		p.onDefault(:direction=>direction,**opts);
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
		v.instance_eval &block;
		@views[vn]=v;
		@defaultView=v unless @defaultView;
	end ##}}}

	##}}}


	## finalize, to finalize the component according with user specified commands
	def finalize; ##{{{
		# 1.eval user nodes
		evalUserNodes(self);
		# 2.if generator is nil, then add a default one: 'link'
		buildDefaultGenerator if @genConfig[:generator]==nil;
		# 3.setup dirs for component.
	end ##}}}

	## elaborate(vname), to build the config according to given generator
	def elaborate(config,**opts) ##{{{
		vname=opts[:view].to_sym if opts.has_key?(:view);
		unless vname
			Rsim.warning("no view is specified of component(#{self.vlnv}), use defaultView(#{@defaultView})"); 
			vname=@defaultView;
		end
		@genConfig[:options][:view]=vname;

		iname = config.design.getInstName(vlnv);
		@genConfig[:options][:out]=File.join(MetaData.out(:components),"#{name}-#{iname}");
		@genConfig[:generator].generate(self,@genConfig[:options]);
	end ##}}}

	## fileSet, return specific fileSets according to current view
	def fileSet(vname) ##{{{
		return @views[vname].fileSet;
	end ##}}}


	## build, called by other internal objects to start building this component by the specified generator
	def build; ##{{{
		g=MetaData.find(@genConfig[:generator],:generatorChain);
		raise NodeException.new("Generator #{name} not defined") unless g;
		g.execute(self,@genConfig[:options]);
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
	#c.outhome= MetaData.outhome;
	MetaData.register(c);
end ##}}}
