"""
# Examples
config :name,:clone=>xxx do
	design :vlnv # specify a design vlnv that for this config 
	need design.componentInstanceName # set component that shall be built in this config
	simulator :name # specify the simulator type.
	# config strings
	compopt '-define xxx'
	elabopt '-xxx xxx'
end
"""

"""
# Object description:
DesignConfiguration, description
"""
require 'lib/nls/IpXactData.rb'
class DesignConfiguration < IpXactData##{{{
	attr :design;
	attr :simulator;
	attr :parent;
	attr :outhome;

	# array of component objects that required to be built.
	attr_accessor :needs;
	attr_accessor :strings;
	#TODO, current in @needs, attr_accessor :components; # stores components that are needed.

	# name of filelist
	attr_accessor :filelist;

	## initialize(id), description
	def initialize(id); ##{{{
		super(id);
		@design=nil;
		@needs=[];
		@simulator=:vcs; # default
		# all config strings are stored.
		@strings={
			:compileOptions  => [],
			:elaborateOptions=> []
		};
		@parent=nil;
		@filelist=File.join(self.outhome(Rsim.ui.outhome),'filelist.f');
		##@components=[];
	end ##}}}
	## outhome, return the home dir of current config, format will be:
	# <OUT>/configs/<id>
	# out arg is the out dir of the current project.
	def outhome(out=nil); ##{{{
		return @outhome unless out;
		@outhome= File.join(out,'configs',@id);
		return @outhome;
	end ##}}}
	## components, return needs
	def components; ##{{{
		#puts "#{__FILE__}:(components) is not ready yet."
		Rsim.info("return components: (#{@needs})",9);
		return @needs;
	end ##}}}
	## addParent(p), add parent config object for this config
	def addParent(p); ##{{{
		@parent=p;
	end ##}}}

	## design(vlnv), api called by config nodes, find and get object from MetaData, this
	# shall be called only at finalize stage that all nodes are loaded.
	# there's only one design in a project
	def design; ##{{{
		unless @design
			@design=MetaData.design;
			raise NodeE.new("design not found, check if correctly declared") unless @design;
		end
		return @design;
	end ##}}}

	## need(o), object directly from design
	def need(o); ##{{{
		@needs << o;
	end ##}}}
	## simulator(n), specify simulator by name
	def simulator(n=nil); ##{{{
		return @simulator unless n;
		@simulator=n.to_sym;
	end ##}}}
	## compopt(s), add config string for compile.
	def compopt(s); ##{{{
		@strings[:compileOptions] << s;
	end ##}}}
	## elabopt(s), description
	def elabopt(s); ##{{{
		@strings[:elaborateOptions] << s;
	end ##}}}
	## finalize, to finalize the config, which need first to finalize
	# the design, then config, then components
	alias self_finalize finalize;
	def finalize; ##{{{
		self.design.finalize;
		self_finalize;
		self.components.each do |c|
			c.finalize;
		end
	end ##}}}
end ##}}}

## config(id,opts={},&block), 
def config(id,opts={},&block); ##{{{
	#puts "#{__FILE__}:(config(id,opts={},&block)) is not ready yet."
	c=MetaData.find(id,:DesignConfiguration);
	c=DesignConfiguration.new(id) if c==nil;
	parent=nil;
	if opts.has_key?(:clone)
		pname=opts[:clone];
		parent=MetaData.find(pname,:DesignConfiguration)
		raise NodeE.new("parent(#{pname}) not defined before cloning by #{id}") if parent==nil;
	end
	c.addParent(parent) if parent!=nil;
	c.addNodes(block.source_location,block);
	MetaData.register(c,:DesignConfiguration);
end ##}}}