"""
# Object description:
UserInterface, 
UI class for processing all user interface and tool configurations
"""
class UserInterface ##{{{
	## initialize, description
	def initialize; ##{{{
		checkEnvValues;
		parseUserInputs;
	end ##}}}
	# detect key ENV variables required by this tool.
	# RSIM_PLUGIN, RSIM_ROOT, STEM
	#TODO
	def checkEnvValues
	end

	# user optparse to setup and processing the user inputs.
	def parseUserInputs
	end


	## commands, return a certain formatted command
	# according to user inputs and inferring the command
	# return commands format required:
	def commands; ##{{{
		puts "#{__FILE__}:(commands) is not ready yet."
		#1.arrange flow commands
		#2.return with the format:
		# format: [{:api=>'build',:opts=>{:config=>:config,:b=>xxx}}]
	end ##}}}
end ##}}}
