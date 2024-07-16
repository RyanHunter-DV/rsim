"""
# Object description:
ToolOptions, object to store and setup tool options used by Rsim, and will first get options
from user command line or ENV, then to setup internal tool options.
"""
class ToolOptions ##{{{
	## initialize, 
	#
	def initialize; ##{{{
		#puts "#{__FILE__}:(initialize) is not ready yet."
		parseEnv; # if env not exists, some may raise exception, some may set a default value
		setupToolOptions;
		parseUI; # parse user commandline
		buildCommands; # build exe commands according to UI,Env info.
	end ##}}}

	## parseUI, parsing the user commandline options, supported:
	# -v <VERBO>: set verbosity of info print
	# -e <EXECMD>: set executing command for this time to invoke the tool
	# -l <LOG>: use user specified log file, instead of the default 'rsim.log', if specified, will be changed to @outdir/current/<log>
	# -j <MAX_JOBS>: specify max job numbers can be issued by tool.
	# -s <STEP,...>: skip specified steps, separate by ','
	def parseUI; ##{{{
		puts "#{__FILE__}:(parseUI) is not ready yet."
		#TODO
	end ##}}}
	## parseEnv, check critical env value, may raise ToolOptionException or use a default value instead.
	# STEM: criticial for this tool
	# OUT_HOME: if not exists, then use default: $STEM/out
	# RSIM_ENTRIES: criticial for this tool, can specify multiple entries splitted by ';'
	# RSIM_EDA: if not exist, then use default: Xcelium
	def parseEnv; ##{{{
		puts "#{__FILE__}:(parseEnv) is not ready yet."
		#TODO
	end ##}}}

	## setupToolOptions, to set other default options
	# maxJobs: by default is 1
	# verbo: for reporter verbosity threshold, default is 5
	# logdir: default is @outhome/logs/current/rsim.log
	def setupToolOptions; ##{{{
		puts "#{__FILE__}:(setupToolOptions) is not ready yet."
		#TODO
	end ##}}}

	## buildCommands, according to skip and exe, calculate the available command steps
	def buildCommands; ##{{{
		puts "#{__FILE__}:(buildCommands) is not ready yet."
		#TODO.
	end ##}}}
end ##}}}