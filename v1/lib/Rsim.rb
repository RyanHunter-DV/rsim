# ----------------------------------------------------------------------------------------------
# The very top level of the whole Rsim tool.
# ----------------------------------------------------------------------------------------------

# The LOAD_PATH of this Rsim tool is ~/rsim/v1/
require 'lib/xxx'
require 'ipxact/xxx'
module Rsim

	## plugin, returns the instance variable of plugin manager in this tool.
	def self.plugins; ##{{{
		@pm = PluginManager.new if @pm==nil;
		return @pm;
	end ##}}}

	## self.ui, return UI, if not exists, build a new one
	def self.userInterface; ##{{{
		puts "#{__FILE__}:(self.ui) is not ready yet."
		@ui = OptionProcessor.new if @ui==nil;
		return @ui;
	end ##}}}

	## self.nm, return the tool's node namager.
	def self.nodes; ##{{{
		puts "#{__FILE__}:(self.nm) is not ready yet."
		@nm=NodeManager.new if @nm==nil;
		return @nm;
	end ##}}}

	## self.dispatcher, return the dispatch manager for threads control, just like plugin/node...
	def self.dispatcher; ##{{{
		puts "#{__FILE__}:(self.dispatcher) is not ready yet."
		@dp=Dispatcher.new if @dp==nil;
		return @dp;
	end ##}}}

	## self.init, initialization of Rsim tool.
	def self.init; ##{{{
		ui = self.userInterface;
		ui.checkEnvValues;
		ui.processUserInputs;
		self.dispatcher.init(:maxJobs=>ui.maxJobs);
		self.plugins.loading(ui); ##TODO, require loading api from plugin/node manager.
		self.nodes.loading(ui);
	end ##}}}
	## self.execute(), 
	# execute the Rsim tool according to ui commands
	# args:
	# - commands is array type arranged by the UserInterface.
	# ['build(:Config)','compile(:Config)']
	def self.execute(commands); ##{{{
		self.plugins.execute(commands);
		commands.each do |dc|
			cmdS = %Q|Rsim.plugins.#{dc}|;
			self.instance_eval cmdS;
		end
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
			ui=self.userInterface;
			self.execute(ui.commands);
		end
	end ##}}}

	##}}}

end
