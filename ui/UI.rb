"""
# Object description:
UI, description
this class cannot call with Rsim.report... can only call Rsim.info
"""
require 'optparse.rb'
class UI

	attr_accessor :options;
	attr_accessor :helpMessage;

	attr_accessor :toolhome;

	# hash attr to store chain information
	# [:names] => {:build=>{options},:node=>{opts},...}
	# [:includes] => [paths]
	# at very init, the chains is nil, need call _setupChains once use it
	attr_accessor :chains;
	attr_accessor :outs;

	attr :formats;
	# array to store all skips
	# ['node','build','sim::compile','sim::elab']
	attr :skipflows;
	attr :__builtinChainPath__;
	## initialize, description
	def initialize; ##{{{
		_initVariables;
		_initToolOptions; # tool options like toolhome
		_initEnvOptions;
		_initUserOptions;
		_parseUserOptions;
		_initOutDirs;
	end ##}}}

	## flowStream, return a hash contains chains
	## and corresponding options to be executed
	## - organize chains according to -e, -s options
	## - get target chain, and according to target chain, infer the required chains
	## - if has skip a chain option, need remove the required default chain.
	## - if no -e provided, then return empty hash {}, and raise a UIE exception.
	# return like: flows={:node=>{option=>xxx,option=>xxx,...},:build=>{xxx},...}
	#TODO
	def flowStream ##{{{
		_setupChains unless @chains;
		return @chains[:names];
	end ##}}}
	## chainNames, return array of all required chain names
	def chainNames ##{{{
		_setupChains unless @chains;
		return @chains[:names].keys.map{|x| x.to_s;};
	end ##}}}
	## chainSearchPath, return the search paths of required chains
	# in array format.
	def chainSearchPath ##{{{
		_setupChains unless @chains;
		return @chains[:includes];
	end ##}}}
	## skipped?(name), return true if given named chain or step is skipped
	# example:
	# for chain: skipped?('build')
	# for step: skipped?('sim::compile')
	def skipped?(name) ##{{{
		return @skipflows.include?(name.to_s);
	end ##}}}
	## skipSteps(chain), return skip steps of given chain name,
	# if not exists, return empty array
	def skipSteps(chain) ##{{{
		s=[];
		chain=chain.to_s;
		@skipflows.each do |sk|
			s << sk.sub(/#{chain}::/,'').to_sym if /#{chain}/ =~ sk;
		end
		Rsim.info("get skipped steps(#{s})",9);
		return s;
	end ##}}}
private
	## _initVariables, set default value and data type of this class attributes
	def _initVariables ##{{{
		@command=nil;
		@options={};
		@skipflows=[];
		@chains=nil; 
	end ##}}}

	## _parseUserOptions, use OptionParser to parse user inputs
	def _parseUserOptions ##{{{
		OptionParser.new() do |opt|
			@formats.each do |fmt|
				block = nil;
				if (fmt[:default].is_a?(FalseClass) or fmt[:default.is_a?(TrueClass)])
					block = Proc.new {
						@options[fmt[:name]] = true;
						if fmt.has_key?(:execute)
							if fmt[:execute].is_a?(String)
								self.instance_eval fmt[:execute];
							else
								self.instance_eval &fmt[:execute];
							end
						end
					};
				else
					block = Proc.new {|v|
						@options[fmt[:name]] = v;
						Rsim.info("options: #{fmt[:name]} -> #{v}",9)
						self.instance_eval &fmt[:execute] if fmt.has_key?(:execute);
					};
				end
				opt.on(fmt[:sflag],fmt[:lflag],fmt[:display],&block);
			end
		end.parse!
	end ##}}}

	## _initOptionFormat, description
	def _initOptionFormat; ##{{{
		@formats = [
			{
				:name=>:version,:sflag=>'-V',:lflag=>'--version',:default=>false,
				:display=>'display version message'
			},
			{
				:name=>:help,:sflag=>'-h',:lflag=>'--help',:default=>false,
				:execute => '@helpMessage=opt;puts opt;exit 0',
				:display=>'display help message'
			},
			{
				:name=>:verbosity,:sflag=>'-v',:lflag=>'--verbo=VERBOSITY',:default=>5,
				:display=>'set max verbosity to display in this tool'
			},
			{
				:name=>:out,:sflag=>'-o',:lflag=>'--out=DIRNAME',:default=>'out',
				:display=>'set out home'
			},
			{
				:name=>:log,:sflag=>'-l',:lflag=>'--log=LOGNAME',:default=>'rsim.log',
				:display=>'set the main log name'
			},
			{
				:name=>:debug,:sflag=>'-d',:lflag=>'--debug',:default=>false,
				:display=>'enable debug mode for this tool'
			},
			{
				:name=>:execute,:sflag=>'-e',:lflag=>'--execute=COMMAND',:default=>nil,
				:display=>%Q|set command for executing\n\texamples:\n\t\trsim -e 'build(ConfigName)'\n\t\trsim -e 'sim(SuiteName/TestName)'|
			},
			{
				:name=>:skip,:sflag=>'-s',:lflag=>'--skip=FLOWNAME',:default=>'',
				#:execute => '@skipflows << @options[:skip].to_s',
				:execute => Proc.new {
					s= @options[:skip].to_s;
					if /:/ =~ s
						_addSkipSteps(s);
					else
						_addSkipChains(s);
					end
					#@skipflows << @options[:skip].to_s
				},
				:display => <<-DOC.gsub(/\t+\../,'')
				..To skip certain flow while running target execute commands
				..\t-s 'build,node' -s 'sim:compile,elab'
				..\t-s 'build'
				DOC
			},
		];
	end ##}}}
	## _initUserOptions, description
	def _initUserOptions; ##{{{
		#puts "#{__FILE__}:start _initUserOptions ..."
		_initOptionFormat;
		@formats.each do |fmt|
			@options[fmt[:name]] = fmt[:default];
		end
	end ##}}}

	## _splitCommandName(cmdS), description
	# -e 'compile(ConfigName)', this is to run sim::compile for certain config, #TODO
	def _splitCommandName(cmdS); ##{{{
		Rsim.info("cmdS: #{cmdS}",9)
		ptrn=Regexp.new(' *(\w+) *\(([\w\/]+)\) *');
		md=ptrn.match(cmdS);
		splitted=[];
		if md
			splitted[0]=md[1];
			splitted[1]=md[2];
		else
			Rsim.exception(UIE,:reason=>"invalid execute command given by '-e': #{cmdS}");
		end
		return splitted;
	end ##}}}
	## _setupUserCommands, description
	def _setupUserCommands(cmdStr); ##{{{
		#TODO, translate input command string into ui formats.
		# 
		command={:name=>'',:opts=>{}};
		splitted = _splitCommandName(cmdStr);
		command[:name]=splitted[0];
		if command[:name]=='build'
			command[:opts][:config]=splitted[1];
		elsif command[:name]=='sim'
			s=splitted[1].split('/');
			Rsim.exception(UIE,:reason=>"invalid command format(#{splitted[1]})") unless s.length==2;
			command[:opts][:suite]=s[0];
			command[:opts][:test]=s[1];
		end
		Rsim.info("get command(#{command})")
		#TODO, for other flows.
		return command;
	end ##}}}
	## _initEnvOptions, description
	def _initEnvOptions; ##{{{
		@options[:ROOT] = nil; # root entry
		@options[:ROOT] = ENV['ROOT'] if ENV.has_key?('ROOT');
		@options[:STEM] = nil; # STEM path, indicates to current project
		@options[:STEM] = File.absolute_path(ENV['STEM']) if ENV.has_key?('STEM');
		# $FLOW_INCS = 'patha/b;pathc/d/'
		@options[:FLOW_INCS]=ENV['FLOW_INCS'] if ENV.has_key?('FLOW_INCS');

		Rsim.exception(UIE,:reason=>"env not correctly set\n#{@options}") unless @options[:STEM] and @options[:ROOT];
	end ##}}}

	## _timestamp, format the current time with following rule:
	# ' ' translated to '__',
	# '-' or ':' translated to '_'
	# '+' removed
	def _timestamp; ##{{{
		tf=Time.now.to_s;
		tf.gsub!(/ /,'__');
		tf.gsub!(/[:-]/,'_')
		tf.gsub!(/\+/,'')
		return tf;
	end ##}}}

	## _initOutDirs, 
	# 1.outs[:root] = File.join(@toolhome,@__ui__.out)
	# 2.outs[:logs] ...
	# 3.outs[:config] -> root dir of config
	# 4.outs[:component] -> root dir of components
	def _initOutDirs; ##{{{
		@outs={};
		@outs[:root]=File.join(@options[:STEM],@options[:out]);
		tf=_timestamp();
		@outs[:logs]=File.join(@outs[:root],'logs',tf)
		#TODO, config, component paths
	end ##}}}
	## _initToolOptions, init options/configs for tool
	# toolhome;
	def _initToolOptions ##{{{
		@toolhome=File.dirname(File.dirname(File.absolute_path(__FILE__)));
		@__builtinChainPath__ =File.join(@toolhome,'chains');
	end ##}}}
	## _setupChains, to setup chains according to options
	# if no @options[:execute], raise UIE
	def _setupChains ##{{{
		@chains={:names=>{},:includes=>[]};
		user =@options[:execute];
		Rsim.exception(UIE,:reason=>'no execute command given') unless user;
		target=_setupUserCommands(user);
		case(target[:name])
		when 'build'
			_setupNode(:config=>target[:opts][:config]) # node flow cannot be skipped
			_setupBuild(:config=>target[:opts][:config]) unless skipped?('build');
		when 'sim'
			s=target[:opts][:suite];t=target[:opts][:test];
			_setupNode(:suite=>s,:test=>t); # node flow cannot be skipped
			_setupBuild(:suite=>s,:test=>t) unless skipped?('build');
			_setupSim(:suite=>s,:test=>t);
		#TODO, more
		end
		# setup includes
		@chains[:includes] << @__builtinChainPath__;
		if @options.has_key?(:FLOW_INCS)
			sps=@options[:FLOW_INCS].split(/;/);
			sps.each do |sp|
				@chains[:includes] << File.absolute_path(sp);
			end
		end
		puts "#{@chains}";
	end ##}}}
	## _parseNodeEntries, to parse the options[:ROOT]: 'aaa/b/root.rh;ccc/d/root.rh;...'
	# into array type
	def _parseNodeEntries ##{{{
		return @options[:ROOT].split(/;/);
	end ##}}}
	## _setupNode, setup the node flow requirements, :skip options if has node step skipped
	def _setupNode(opts={}) ##{{{
		s=skipSteps('node');
		opts[:skip]=s;
		opts[:entries]=_parseNodeEntries;
		@chains[:names][:node]=opts;
	end ##}}}
	## _setupBuild, setup the build flow requirements,
	# options:
	# :skip
	# :config
	def _setupBuild(opts={}) ##{{{
		s=skipSteps('build');
		opts[:skip]=s;
		@chains[:names][:build]=opts;
	end ##}}}
	## _setupSim(), setup sim flow with given options
	def _setupSim(opts={}) ##{{{
		s=skipSteps('sim');
		opts[:skip]=s;
		opts[:skip] << :build if skipped?('build');
		Rsim.info("sim options(#{opts})",9);
		@chains[:names][:sim]=opts;
	end ##}}}

	## _addSkipSteps(s), pattern process the input string of skip steps and append to @skipflows
	def _addSkipSteps(s) ##{{{
		ptrn=Regexp.new(/(\w+):([\w,]+)/);
		md=s.match(ptrn)
		Rsim.exception(UIE,:reason=>"invalid skip option #{s}") unless md;
		chain=md[1];
		steps=md[2].split(/ *, */);
		steps.each do |st|
			@skipflows << chain+'::'+st;
		end
	end ##}}}
	## _addSkipChains(s), pattern process the skipped chains
	def _addSkipChains(s) ##{{{
		chains=s.split(/ *, */);
		chains.each do |st|
			@skipflows<<st;
		end
	end ##}}}
end
