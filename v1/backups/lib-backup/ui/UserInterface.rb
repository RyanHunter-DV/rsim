"""
# Object description:
UserInterface, 
UI class for processing all user interface and tool configurations
"""
require 'lib/erh/EnvException'
require 'optparse';
class UserInterface

	EnvVars={:entries=>'RSIM_ROOT',:stem=>'STEM'};
	attr_accessor :maxJobs;
	attr_accessor :logdir; # the OUT/logs dir by default
	attr_accessor :plugins;
	attr_accessor :verbo;
	attr_accessor :outhome;
	attr :execute;
	attr :outdir;

	# ENV variables
	attr_accessor :stem;
	attr_accessor :entries;
	attr_accessor :eda;

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
		EnvVars.each_pair do |lv,ev|
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
		@maxJobs=1;@logdir='logs';@plugins=[];
		@verbo=5;@execute='';
		@outdir='out'; #default
		processEnvVars;
		Rsim.info("Tool config initialized:",9);
		Rsim.info("eda: #{@eda}",9);
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
		@eda=ENV['RSIM_EDA'].to_sym if ENV['RSIM_EDA'];
		setupSimulatorType(ENV['RSIM_EDA']);
	end ##}}}
	## setupSimulatorType(t), process t from env and setup @eda
	def setupSimulatorType(t) ##{{{
		t=t.downcase.capitalize.to_sym if t.is_a?(String);
		if t
			@eda = t;return if t==:Vcs or :Xcelium;
			Rsim.warning("unrecognized simulator name(#{t}), ignored");
		end
		Rsim.info("setup default eda:#{@eda}",6);
		@eda=:Xcelium; return;
	end ##}}}

	# user optparse to setup and processing the user inputs.
	def parseUserInputs
		OptionParser.new() do |opts|
			opts.on('-v','--verbo=VERBO','set verbosity for report') do |v|
				@verbo=v.to_i;
			end
			opts.on('-e','--exe=COMMAND','set user execute command') do |v|
				# examples
				# -e 'build(:ConfigName)', to build a specific config
				@execute=v;
			end
			opts.on('-o','--out=DIR','specify a new out dir instead of the default') do |v|
				@outdir=v;
			end
		end.parse!

		@outhome=File.join(@stem,@outdir);
		@logdir=File.join(@outhome,@logdir);
		Rsim.info("setting outhome: #{@outhome}",9);
	end

	## filterUserCmd(exe), filter the format like 'build(:config)' into
	# {:api=>:build,:opts=>{:config=>'config',...}}
	def filterUserCmd(exe) ##{{{
		re=Regexp.new(/(\w+)\(:*(\w+)\)/);
		md=re.match(exe.gsub(/ /,''));
		if md
			cmd={:api=>md[1],:opts=>{:config=>md[2].to_sym}};
			return cmd;
		end
		raise NodeException.new("invalid command entered:(#{exe})");
	end ##}}}

	## commands, return a certain formatted command
	# according to user inputs and inferring the command
	# return commands format required:
	def commands; ##{{{
		cmds=[];
		#1.arrange flow commands
		cmds << filterUserCmd(@execute) if @execute!='';
		return cmds if cmds.empty?;
		case(cmds[0][:api])
		when 'compile'
			insertCmd(:build,cmds);
		when 'runtest'
			insertCmd(:compile,cmds);
			insertCmd(:build,cmds);
		end
		#2.return with the format:
		# format: [{:api=>'build',:opts=>{:config=>:config,:b=>xxx}}]
		return cmds;
	end ##}}}
end
