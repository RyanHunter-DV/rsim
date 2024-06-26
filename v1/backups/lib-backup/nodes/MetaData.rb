require 'lib/erh/NodeException.rb'
require 'lib/erh/ToolException.rb'
require 'lib/ipxact/IpXactData.rb'
require 'lib/ipxact/component/PortType.rb'
require 'lib/ipxact/abstraction/AbsWirePort.rb'
require 'lib/ipxact/design/PortMap.rb'
require 'lib/ipxact/design/Design.rb'
require 'lib/ipxact/config/DesignConfiguration.rb'
require 'lib/ipxact/component/BusInterfaceType.rb'
require 'lib/ipxact/component/ViewType.rb'
require 'lib/ipxact/component/WirePort.rb'
#require 'lib/ipxact/component/ComponentModel.rb'
require 'lib/ipxact/component/AddressBlock.rb'
require 'lib/ipxact/component/AddressBank.rb'
require 'lib/ipxact/component/MemoryMapCommands.rb'
require 'lib/ipxact/component/FileSetType.rb'
require 'lib/ipxact/component/Component.rb'
require 'lib/ipxact/component/RegisterType.rb'
require 'lib/ipxact/component/RegisterFieldType.rb'
require 'lib/ipxact/component/MemoryMap.rb'
require 'lib/ipxact/component/TransPort.rb'
require 'lib/ipxact/BusDefinition.rb'
require 'lib/ipxact/Generator.rb'
require 'lib/ipxact/tests/TestTemplate.rb'
require 'lib/ipxact/tests/Test.rb'
require 'lib/Shell'
module MetaData

	@pool={
		:busDefinition=>{},:abstractionDefinition=>{},
		:component=>{},:design=>{},:config=>{},
		:generatorChain=>{}
	};
	@outhome='';

	## self.outhome, return outhome of current project
	def self.outhome(v='') ##{{{
		caller(1);
		Rsim.info("metadata's outhome: (#{@outhome}),v(#{v})",9);
		return @outhome if v=='';
		@outhome=v;
	end ##}}}
	# pool: pool[<datatype>] = {<name> => <object>,...}
	def self.register(c)
		dt  = c.datatype;
		name= c.id.to_s;
		Rsim.info("register #{name} of type #{dt}",9);
		@pool = {} unless @pool;
		@pool[dt]={} unless @pool.has_key?(dt);
		if @pool[dt].has_key?(name)
			raise NodeException.new("name(#{name}) of object(#{dt}) has been registered before")
		else
			@pool[dt][name]=c;
		end
		@design = c if dt==:design;
		return;
	end
	## self.configs(cn), return the registered config object of given name
	def self.configs(cn) ##{{{
		return self.find(cn,:config);
	end ##}}}

	# find in specifid type pool by given t, according to given name.
	# name is a string: MetaData.find('vlnv',:component)
	def self.find(name,t)
		t=t.to_sym;name=name.to_s;
		item=nil;
		pool = @pool[t] if @pool.has_key?(t);
		item=pool[name] if pool.has_key?(name);
		unless item
			raise NodeException.new("cannot find object:(#{name}) by given type: #{t}\nfollowing are availables:#{pool.keys}");
		end
		return item;
	end

	# generators can be built before finalize phase
	# eval the generator block and register into @pool[:generator]
	#TODO
	def self.buildGenerator
	end

	# TODO, need figure out what want to finalize.
	# eval existing node blocks for every node, elaborate and arrange database
	# 1. finalize bus definitions
	# 2. finalize abstraction definitions
	# 3. finalize all components: comp -> view, interconnect ...
	# 4. finalize design
	# 5. finalize all configs, this is different with flow executing, finalize only optimize
	# the internal metadata in Rsim, will not do any build relative actions.
	def self.finalize
		## finalize all bus definition.
		Rsim.info("finalizing BusDefinition ... ...",4);
		@pool[:busDefinition].each_pair do |n,o|
			Rsim.info("finalizing #{n} ...",9);
			o.finalize;
		end
		Rsim.info("finalizing abstraction ... ...",4);
		@pool[:abstractionDefinition].each_pair do |n,o|
			Rsim.info("finalizing #{n} ...",9);
			o.finalize;
		end
		Rsim.info("finalizing component ... ...",4);
		@pool[:component].each_pair do |n,o|
			Rsim.info("finalizing #{n} ...",9);
			o.finalize
		end
		Rsim.info("finalizing design ... ...",4);
		@pool[:design].each_pair do |n,o|
			Rsim.info("finalizing #{n} ...",9);
			o.finalize;
		end
		Rsim.info("finalizing configs ... ...",4);
		@pool[:config].each_pair do |n,o|
			Rsim.info("finalizing #{n} ...",9);
			o.finalize;
		end
	end
	## self.buildDirs, to build common dirs:
	# - @outhome
	# - @outhome/components
	# - @outhome/configs
	# - @outhome/common
	def self.buildDirs ##{{{
		@out={};
		@out[:components]=File.join(@outhome,'components');
		@out[:configs]=File.join(@outhome,'configs');
		@out[:common]=File.join(@outhome,'common');
		Shell.makedir @out[:components],@out[:configs],@out[:common]
	end ##}}}
	## self.out(t), return out path according to given type
	def self.out(t=nil) ##{{{
		return @outhome unless t; # if t is nil, return the root path.
		return @out[t.to_sym];
	end ##}}}

	## self.elaborate(cn), elaborate the given config name
	def self.elaborate(cn) ##{{{
		config=self.find(cn,:config);
		raise NodeException.new("config(#{cn} not found") unless config;
		Rsim.info("start building config #{cn}",5);
		self.buildDirs;
		config.elaborate;
	end ##}}}

	def self.design
		# return the design object
		return @design;
	end
end
