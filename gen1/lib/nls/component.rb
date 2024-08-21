"""
# Object description:
Component, The IP-XACT component object
"""
require 'lib/nls/IpXactData.rb'
require 'lib/nls/fileSet.rb'
require 'lib/nls/view.rb'

"""
# Object description:
ComponentInstance, description
"""
class ComponentInstance ##{{{
	attr :name;
	# the object of Component in a ComponentInstance.
	attr :componentObject;
	## initialize(name), description
	def initialize(n,o); ##{{{
		@name= n; @componentObject=o;
	end ##}}}

	## outhome, return out dir of current instantiated component, format:
	# $OUT/components/<componentid-instancename>
	def outhome; ##{{{
		chome=%Q|#{@componentObject.id}-#{@name}|;
		return File.join(Rsim.ui.outhome,'components',chome);
	end ##}}}
	## fileSets, return the component fileSets
	def fileSets; ##{{{
		return @componentObject.fileSets;
	end ##}}}
	## generator, return component generator
	def generator; ##{{{
		return @componentObject.generator;
	end ##}}}
	## type, return the real component object
	def type; ##{{{
		return @componentObject;
	end ##}}}
	## generatorOptions, description
	def generatorOptions; ##{{{
		puts "#{__FILE__}:(generatorOptions) is not ready yet."
		return {};
	end ##}}}

	## finalize, description
	def finalize; ##{{{
		@componentObject.finalize;
	end ##}}}
	## id, description
	def id; ##{{{
		return @componentObject.id;
	end ##}}}

end ##}}}
class Component < IpXactData ##{{{

	attr :generator;
	attr :as;
	attr_accessor :fileSets;

	## initialize(vlnv), description
	def initialize(vlnv); ##{{{
		super(vlnv);
		@generator=nil;
		@fileSets={
			:source=>{}, # store source files
			:target=>{} # for target generated files
		};
		@views={}; @as={};
	end ##}}}


	## generator(n=nil), 
	# if given n, then specify the generator name, else return the generator name
	def generator(n=nil); ##{{{
		return @generator unless n;
		@generator= n.to_sym;
	end ##}}}

	## fileSet(id,&block), define fines for a certain fileSet
	def fileSet(id,&block); ##{{{
		id=id.to_s;
		fs=FileSet.new(id,block.source_location);
		fs.instance_eval &block;
		@fileSets[:source][fs.id] = fs;
	end ##}}}

	## view(id,&block), declare a new view if id not exists,
	# or else to eval based on previously declared view
	def view(id,&block); ##{{{
		id=id.to_sym; v=nil;
		v=@views[id] if @views.has_key?(id);
		v=View.new(id,self) if v==nil;
		v.instance_eval &block;
	end ##}}}

	## instantiatedAs(iname), add one instance information for design top.
	# One component object can have multiple instances, will create a new instance class
	# to operate instance information in the future.
	def instantiatedAs(iname); ##{{{
		iname=iname.to_s;
		a=ComponentInstance.new(iname,self);
		@as[iname]=a;
	end ##}}}
	## instanceObject(iname), according to name, return the instance object
	def instanceObject(iname); ##{{{
		iname=iname.to_s;
		raise NodeE.new("instance(#{iname}) not instantiated by design") unless @as.has_key?(iname);
		return @as[iname];
	end ##}}}
	
end ##}}}

## component(vlnv,&block), 
# declare a component object in user node.
def component(vlnv,&block); ##{{{
	c=MetaData.find(vlnv,:Component);
	c=Component.new(vlnv) if c==nil;
	c.addNodes(block.source_location,block);
	MetaData.register(c,:Component);
end ##}}}