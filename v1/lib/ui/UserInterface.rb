"""
# Object description:
UserInterface, 
UI class for processing all user interface and tool configurations
"""
require 'lib/erh/EnvException'
require 'optparse';
class UserInterface

	attr_accessor :maxJobs;
	attr_accessor :logdir;
	attr_accessor :plugins;
	attr_accessor :verbo;

	# ENV variables
	attr_accessor :stem;
	attr_accessor :entries;

	## initialize, description
	def initialize; ##{{{
		checkEnvValues;
		initFields;
		parseUserInputs;
	end ##}}}
	# detect key ENV variables required by this tool.
	# RSIM_PLUGIN, RSIM_ROOT, STEM
	#TODO
	def checkEnvValues
		reason='env($ENV_VAR) not detected';
		vars={:entries=>'RSIM_ROOT',:stem=>'STEM'};
		vars.each_pair do |lv,ev|
			if ENV[ev]
				self.instance_variable_set("@#{lv}",ENV[ev]);
			else
				replaced=reason.sub(/ENV_VAR/,ev) 
				raise EnvException.new(replaced);
			end
		end
	end

	## initFields, initialize local field by default value.
	def initFields ##{{{
		@maxJobs=1;@logdir='.';@plugins=[];
		@verbo=5;
		processEnvVars;
	end ##}}}
	## processEnvVars, the field indicates the env value that shall be set
	## in checkEnvValues, but for special vars such as paths shall be furthor
	## processed here.
	def processEnvVars ##{{{
		@stem=File.absolute_path(@stem);
		raise EnvException.new("stem(#{@stem}) not a valid path") unless File.exists?(@stem);
		Rsim.info("ENV-STEM(#{@stem})",6);
		@entries=@entries.split(';');
		Rsim.info("ENV-RSIM_ROOT(#{@entries})",6);
	end ##}}}

	# user optparse to setup and processing the user inputs.
	def parseUserInputs
		OptionParser.new() do |opts|
			opts.on('-v','--verbo=VERBO','set verbosity for report') do |v|
				@verbo=v.to_i;
			end
		end.parse!
	end


	## commands, return a certain formatted command
	# according to user inputs and inferring the command
	# return commands format required:
	def commands; ##{{{
		cmds=[];
		#1.arrange flow commands
		#2.return with the format:
		# format: [{:api=>'build',:opts=>{:config=>:config,:b=>xxx}}]
		return cmds;
	end ##}}}
end
