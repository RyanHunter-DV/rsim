module Rsim
	# TODO, description here
	# tool top module, which has tool specific objects and apis that can be 

	@options=nil;
	@reporter=nil;
	@pm=nil;
	@patcher=nil;

	# report apis #
	## self.info, called by other components to report by info severity
	# verbosity, according to user interface setting, if current message's verbo > than
	# option setting, then will not been displayed.
	def self.info(msg,verbo=5); ##{{{
		puts "#{__FILE__}:(self.info) is not ready yet."
	end ##}}}
	## self.warning(msg), called by other components for warning severity
	def self.warning(msg); ##{{{
		puts "#{__FILE__}:(self.warning(msg)) is not ready yet."
	end ##}}}

	## self.ui, return ToolOptions object if created, or create a new one and return it.
	def self.options; ##{{{
		@options = ToolOptions.new() unless @options;
		return @options;
	end ##}}}

	## self.init, tool initialization
	def self.init; ##{{{
		puts "#{__FILE__}:(self.init) is not ready yet."
		# 1.tool option initialize, 
		# 1.1.process user command options
		# 1.2.check and get ENV variable values.
		# 1.3.setup default options if user not specified but can be infered by tool.
		options= self.options;
		# 2.report init.
		# 2.1.set verbo threshold from user inputs.
		@reporter = Reporter.new(options.verbo);
		#TODO
		
	end ##}}}

	## self.patcher, return patcher for multi-thread job control, if not exists, then create a new one.
	def self.patcher; ##{{{
		puts "#{__FILE__}:(self.patcher) is not ready yet."
		# @patcher = Dispatcher.new() unless @patcher;
		# return @patcher
	end ##}}}

	## self.pm, return the @pm; if not exists @pm, then create a new one
	def self.pm; ##{{{
		@pm=PluginManager.new(self.patcher,self.options) unless @pm;
		return @pm;
	end ##}}}

	## self.run, called by the tool shell, to start the main procedures
	def self.run; ##{{{
		puts "#{__FILE__}:(self.run) is not ready yet."
		# 1.tool initialization, call init
		self.init;
		# 2.execute commands from self.options, the commands will be executed by PluginManager
		self.pm.execute();
	end ##}}}
end