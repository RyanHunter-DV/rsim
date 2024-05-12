# ----------------------------------------------------------------------------------------------
# The very top level of the whole Rsim tool.
# ----------------------------------------------------------------------------------------------

# The LOAD_PATH of this Rsim tool is ~/rsim/v1/
require 'lib/Reporter.rb'
module Rsim

	def self.pm
		return @pm;
	end

	## self.init, initialization of Rsim tool.
	def self.init; ##{{{

		@ui = UserInterface.new;
		# multiple thread controll system.
		@dp=Dispatcher.new(@ui);
		@pm=PluginManager.new(@dp,@ui);
		@nm=NodeManager.new(@ui);
		@reporter=Reporter.new(@ui.verbo);
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
		end
	end ##}}}

	def self.info(msg,verbo=5)
		raise ToolException.new("displayer been called before initialized") unless @reporter;
		@reporter.info(msg,verbo);
	end
	def self.error(msg)
		raise ToolException.new("displayer been called before initialized") unless @reporter;
		@reporter.error(msg);
	end

	##}}}

end
