# ----------------------------------------------------------------------------------------------
# The very top level of the whole Rsim tool.
# ----------------------------------------------------------------------------------------------

module Rsim

	## plugin, returns the instance variable of plugin manager in this tool.
	def self.plugin; ##{{{
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
	def self.node; ##{{{
		puts "#{__FILE__}:(self.nm) is not ready yet."
		@nm=NodeManager.new if @nm==nil;
		return @nm;
	end ##}}}

	## self.dispatcher, return the dispatch manager for threads control, just like plugin/node...
	def self.dispatcher; ##{{{
		puts "#{__FILE__}:(self.dispatcher) is not ready yet."
		@dp=ThreadController.new if @dp==nil;
		return @dp;
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
		ui = self.userInterface;
		begin
			ui.checkEnvValues;
			ui.processUserInputs;
			self.plugin.loading(ui); ##TODO, require loading api from plugin/node manager.
			self.node.loading(ui);

			#TODO, after the plugins are loaded and setup according to ui, it's ready to execute
			# the plugins.
			# Call plugin manager's execute can start executing plugins in different phase, and each plugin
			# will have different steps.
			self.plugin.execute(self.dispatcher);
		end
	end ##}}}

	##}}}

end