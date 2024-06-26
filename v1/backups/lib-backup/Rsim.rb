# ----------------------------------------------------------------------------------------------
# The very top level of the whole Rsim tool.
# ----------------------------------------------------------------------------------------------

# The LOAD_PATH of this Rsim tool is ~/rsim/v1/
require 'lib/erh/ToolException.rb'
require 'lib/erh/NodeException.rb'
require 'lib/Reporter.rb'
require 'lib/ui/UserInterface.rb'
require 'lib/threads/Dispatcher.rb'
require 'lib/plugin/PluginManager.rb'
require 'lib/nodes/NodeManager.rb'
require 'lib/nodes/MetaData.rb'
require 'lib/simulators/Simulator.rb'
require 'lib/simulators/Vcs.rb'
require 'lib/simulators/Xcelium.rb'
module Rsim

	@reporter;
	@simulator;
	@ui;@dp;@pm;@nm;

	## self.simulator, return a pre-defined simulator object.
	def self.simulator ##{{{
		#raise ToolException.new("no simulator initialized") unless @simulator;
		@simulator=Simulator.new(self.ui.eda) unless @simulator;
		return @simulator;
	end ##}}}

	## self.ui, return @ui, if not exists, then create it
	def self.ui ##{{{
		@ui = UserInterface.new unless @ui;
		return @ui;
	end ##}}}

	def self.pm
		@pm=PluginManager.new() unless @pm;
		return @pm;
	end

	## self.buildDirs, build dir for Rsim tool, the out, and log dir for tool
	#
	def self.buildDirs ##{{{
		Shell.makedir self.ui.outhome,self.ui.logdir;
	end ##}}}

	## self.dp, return the Dispatcher
	def self.dp ##{{{
		return @dp;
	end ##}}}

	## self.init, initialization of Rsim tool.
	def self.init; ##{{{
		# multiple thread controll system.
		@dp=Dispatcher.new(self.ui);
		self.pm.init(@dp,self.ui);
		@nm=NodeManager.new(self.ui);
		Rsim.info("set to metadata: #{self.ui.outhome}",9);
		MetaData.outhome(self.ui.outhome);
		self.buildDirs;
		@reporter=Reporter.new(self.ui.verbo);
	end ##}}}

	## The main entry of Rsim tool, ##{{{
	## self.run, 
	# the very top run api called by the bin/rsim, this api will
	# start the tool and collect all errors.
	# Tool executing flow:
	# 1. ENV check
	# 2. loading UI, user options
		# 1. user option check.
		# 2. arrange user input commands.
	# 3. load plugins
	# 4. load nodes ➝ elaborate
	# 5. build if has
	# 6. compile if has
	# 7. run if has
	def self.run; ##{{{
		begin
			self.init;
			MetaData.finalize; # after loading nodes, need to finalize the data base
			@pm.execute(@ui.commands);
		rescue EnvException => e
			e.process;
		rescue NodeException => e
			e.process;
		rescue ToolException => e
			e.process;
		end
	end ##}}}

	def self.info(msg,verbo=5)
		if @reporter
			@reporter.info(msg,verbo);
		else
			puts "[RAW-I]"+msg;
		end
	end
	## self.warning(msg), report warning
	def self.warning(msg) ##{{{
		if @reporter
			@reporter.warning(msg);
		else
			puts "[RAW-W]"+msg;
		end
	end ##}}}
	def self.error(msg)
		if @reporter
			@reporter.error(msg);
		else
			puts "[RAW-E] #{msg}";
		end
	end

	## self.join(*args), join args into a full path file with absolute path
	def self.join(*args) ##{{{
		f=File.join(*args);
		return File.absolute_path(f);
	end ##}}}

	##}}}

end
