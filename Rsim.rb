require 'libs/MessageReport.rb'
require 'ui/entry.rb'
require 'libs/RsimConfig.rb'
require 'libs/PluginManager.rb'
require 'os/entry.rb'
require 'exceptions/entry.rb'
module Rsim

	@os=nil; @pm=nil; @config=nil;
	@report=nil;
	@loadContext=nil;

	FINTERNAL = 1;

	## self.loadContext(c=nil), description
	def self.loadContext(o=nil); ##{{{
		#puts "#{__FILE__}:start self.loadContext(c=nil) ..."
		return @loadContext unless o;
		@loadContext=o;
	end ##}}}
	## self.exception(et,**opts), raise an exception
	# et -> the exception object
	# opts:
	# [:reason], reason to raise the exception.
	# [:exit], to exit immediately or not ,default is true
	def self.exception(et,**opts); ##{{{
		#puts "#{__FILE__}:start self.exception(et,**opts) ..."
		opts[:stack]=caller(0).join("\n");
		e=et.new(**opts);
		raise e;
	end ##}}}
	## self.report, description
	def self.report; ##{{{
		#puts "#{__FILE__}:start self.report ..."
		if @report==nil
			@report = MessageReport.new;
		end
		return @report;
	end ##}}}
	## self.info(msg,verbo=2), description
	def self.info(msg,verbo=2,depth=1); ##{{{
		#loc=caller(1)[0];
		#callDepth=1;
		self.report.info(msg,depth,verbo);
	end ##}}}

	## self.os, description
	def self.os; ##{{{
		self.report.fatal(FINTERNAL,"os is referenced before initialized") unless @os;
		return @os;
	end ##}}}

	## self.init, tool initialization
	def self.init; ##{{{
		@ui=UI.new;
		@config=RsimConfig.new(@ui);
		@os=OS.new(@config.ostype); # related to OS operations
		@pm=PluginManager.new;
		self.report.setupConfig(@config,@ui);
	end ##}}}

	## self.run, 
	# running the main tool
	def self.run; ##{{{
		begin
			# 1.call self.init that can automatically initialize.
			info("Rsim tool initializing ...",3);
			self.init;
			# 2.plugins dynamic loading
			info("loading plugins ...",3);
			self.loadPlugins;
			info("executing commands ...",3);
			self.execute;
		rescue RsimExceptionBase => e
			#TODO, may need more actions such for job controls etc.
			self.report.error("captured exception #{e.type}, exited: #{e.exit?}");
			self.report.error("reason: #{e.reason}");
			self.report.error("\n-- Stack information: --\n#{e.stack}")
			return e.exitSignal if e.exit?;
		rescue Interrupt => e
			self.info ("get user interrupt signal: #{e.signo}")
			self.info("get user interrupt signal: #{e.signo}")
		end
		return 0;
	end ##}}}
	## self.pm, description
	def self.pm; ##{{{
		return @pm;
	end ##}}}
	## self.execute, 
	# execute commands by given from config, executed by the plugin manager
	def self.execute; ##{{{
		#puts "#{__FILE__}:start self.execute ..."
		@pm.execute(@config.executeFlows);
	end ##}}}

	## self.loadPlugins, 
	def self.loadPlugins; ##{{{
		#puts "#{__FILE__}:(self.loadPlugins) is not ready yet."
		@pm.dynamicLoading(@config.requiredPlugins,@config.pluginPaths);
	end ##}}}
end