"""
# Object description:
UI, description
this class cannot call with Rsim.report... can only call Rsim.info
"""
require 'optparse.rb'
class UI

	attr_accessor :options;
	attr_accessor :helpMessage;
	attr_accessor :command;

	attr :formats;
	attr :skipflows;
	## initialize, description
	def initialize; ##{{{
		_initVariables;
		_initEnvOptions;
		_initUserOptions;
		_parseUserOptions;
		#TODO, help/version mode pre-process
		#_setupUserCommands(@options[:execute]) unless @options[:execute]=='';
	end ##}}}

	## skipped?(name), return true if given flow name is skipped
	def skipped?(name); ##{{{
		#puts "#{__FILE__}:start skipped?(name) ..."
		return true if @skipflows.include?(name.to_s);
		return false;
	end ##}}}

	## flowStream, return a hash contains chains
	## and corresponding options to be executed
	## - organize chains according to -e, -s options
	## - get target chain, and according to target chain, infer the required chains
	## - if has skip a chain option, need remove the required default chain.
	## - if no -e provided, then return empty hash {}, and raise a UIE exception.
	#TODO
	def flowStream ##{{{
	end ##}}}
private
	## _initVariables, set default value and data type of this class attributes
	def _initVariables ##{{{
		@command=nil;
		@options={};
		@skipflows=[];
	end ##}}}

	## _parseUserOptions, use OptionParser to parse user inputs
	def _parseUserOptions ##{{{
		OptionParser.new() do |opt|
			@formats.each do |fmt|
				block = nil;
				if (fmt[:default].is_a?(FalseClass) or fmt[:default.is_a?(TrueClass)])
					block = Proc.new {
						@options[fmt[:name]] = true;
						self.instance_eval fmt[:execute] if fmt.has_key?(:execute);
					};
				else
					block = Proc.new {|v|
						@options[fmt[:name]] = v;
						Rsim.info("options: #{fmt[:name]} -> #{v}",9)
						self.instance_eval fmt[:execute] if fmt.has_key?(:execute);
					};
				end
				opt.on(fmt[:sflag],fmt[:lflag],fmt[:display],&block);
			end
		end.parse!
	end ##}}}

	## _initOptionFormat, description
	def _initOptionFormat; ##{{{
		#puts "#{__FILE__}:start _initOptionFormat ..."
		@formats = [
			{
				:name=>:version,:sflag=>'-V',:lflag=>'--version',:default=>false,
				:display=>'display version message'
			},
			{
				:name=>:help,:sflag=>'-h',:lflag=>'--help',:default=>false,
				:execute => '@helpMessage=opt',
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
				:name=>:debug,:sflag=>'-d',:lflag=>'--debug',:default=>false,
				:display=>'enable debug mode for this tool'
			},
			{
				:name=>:execute,:sflag=>'-e',:lflag=>'--execute=COMMAND',:default=>'',
				:display=>%Q|set command for executing\n\texamples:\n\t\trsim -e 'buildflow(ConfigName)'\n\t\trsim -e 'runflow(SuiteName/TestName,skip=>compile)'|
			},
			{
				:name=>:skip,:sflag=>'-s',:lflag=>'--skip=FLOWNAME',:default=>'',
				:execute => '@skipflows << @options[:skip].to_s',
				:display=>%Q|To skip certain flow while running target execute commands|
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
	def _splitCommandName(cmdS); ##{{{
		#puts "#{__FILE__}:start _splitCommandName(cmdS) ..."
		Rsim.info("cmdS: #{cmdS}",9)
		ptrn=Regexp.new(' *(\w+) *\((\w+)\) *');
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
		@command={:name=>'',:opts=>{}};
		splitted = _splitCommandName(cmdStr);
		@command[:name]=splitted[0];
		if @command[:name]=='buildflow'
			@command[:opts][:config]=splitted[1];
		end
		Rsim.info("get command(#{@command})")
		#TODO, for other flows.
	end ##}}}
	## _initEnvOptions, description
	def _initEnvOptions; ##{{{
		#puts "#{__FILE__}:start _initEnvOptions ..."
		@options[:ROOT] = nil; # root entry
		@options[:ROOT] = ENV['ROOT'] if ENV.has_key?('ROOT');
		@options[:STEM] = nil;
		@options[:STEM] = ENV['STEM'] if ENV.has_key?('STEM');

		#TODO, test for 
		#Rsim.info("test for fixed env");
		#@options[:STEM]='D:/Obsidian/Obsidian/01-Project/rsim/tests';
		#@options[:ROOT]='D:/Obsidian/Obsidian/01-Project/rsim/tests/root.rh';

		Rsim.exception(UIE,:reason=>"env not correctly set\n#{@options}") unless @options[:STEM] and @options[:ROOT];
	end ##}}}
end
