# by default the LOAD_PATH shall have $RSIM_ROOT/<version>
## #project/infra/rsim/object
## 
## This file will be generated into Rsim.rb source file with current contents in comments.
## The is the module of main application, called by the bin/rsim executor directly through the `Rsim.run`
## 
## # module Rsim

require 'lib/exceptions.rb'
require 'lib/report.rb'
require 'lib/ui.rb'
require 'lib/MetaData.rb'
module Rsim
	@reporter=nil;
	@ui=nil;
	## ## def self.run
	## self.run, called by rsim shell, to run the tool
	## The entry to execute this tool.
	## 1. Tool initialize, [[#def init|self.init]]
	## 2. Loading plugins.
	## 3. Execute plugin commands from UI organized.
	def self.run; ##{{{
		begin
			self.init;
			Rsim.info("Start loading nodes ...",9);
			MetaData.loading(@ui.entries);
			@ui.commands.each do |command|
				self.instance_eval command;
			end
		rescue FatalE => e
			e.process();
		rescue NodeE => e
			e.process();
		end
	end ##}}}
	## self.exit(sig), to exit the Rsim tool
	def self.exit(sig); ##{{{
		Kernel.exit(sig);
	end ##}}}
	## ## def self.init
	## 1. Init report system, with default verbosity before UI loaded, require lib/report.rb: [[lib/report.rb#class Reporter#def initialize|Reporter.new]].
	## 2. Init UI system by creating the new object, require lib/ui.rb, [[lib/ui.rb#def initialize|UserInterface.new]]
	## 3. Update the reporter's option from ui.
	## 	1. [[lib/report.rb#class Reporter#def initFromUI|initFromUI(ui)]]
	## 
	## self.init, tool initialization
	def self.init; ##{{{
		@reporter = Reporter.new; # build with basic report features.
		@ui=UserInterface.new;
		@reporter.setupVerboLimit(@ui.maxVerbo);
		@reporter.initLog(@ui.loghome,@ui.mainlog);
		self.info("Logger initialized")
	end ##}}}

	# report message through Rsim ##{{{
	## sefl.info(msg,verbo=5,actions=[]), description
	def self.info(msg,verbo=5,actions=[]); ##{{{
		@reporter.info(msg,verbo,actions);
	end ##}}}
	## self.error(msg,actions=[]), description
	def self.error(msg,actions=[]); ##{{{
		@reporter.error(msg,actions);
	end ##}}}
	## self.fatal(msg,actions=[]), description
	def self.fatal(msg,actions=[]); ##{{{
		@reporter.fatal(msg,actions);
	end ##}}}
	##}}}
end