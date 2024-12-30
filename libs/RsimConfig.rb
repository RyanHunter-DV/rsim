"""
# Object description:
RsimConfig, description
tool configuration panel.
"""
class RsimConfig ##{{{

	attr_accessor :ostype;
	attr_accessor :reportMaxVerbosity;
	attr_accessor :toolhome;
	attr_accessor :executeFlows;
	attr_accessor :outs;

	attr :__ui__;
	## initialize, description
	def initialize(ui); ##{{{
		#puts "#{__FILE__}:start initialize ..."
		@__ui__ = ui;
		_initToolHome;
		_initOSType;
		_initMaxVerbo(ui.options[:verbosity])
		_initExecuteFlows;
		_initoutDirs;
	end ##}}}

	## requiredPlugins, return plugins required by user input commands
	def requiredPlugins; ##{{{
		#puts "#{__FILE__}:start requiredPlugins ..."
		# TODO, testing node flow
		#return ['toolshow','nodeflow'];
		return @executeFlows.keys;
	end ##}}}
	## pluginPaths, return search paths for plugin
	def pluginPaths; ##{{{
		#puts "#{__FILE__}:start pluginPaths ..."
		#TODO, testing node flow
		ps=[];
		ps << File.join(self.toolhome,'plugins');
		ps << File.join(self.toolhome,'plugins','node');
		ps << File.join(self.toolhome,'plugins','build');
		return ps;
		
	end ##}}}

private
	## _setOSType, description
	def _initOSType; ##{{{
		#puts "#{__FILE__}:start _setOSType ..."
		platform=RUBY_PLATFORM;
		if platform=~/mingw/
			@ostype=:Windows;
		else
			@ostype=:Linux;
		end
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
	## _initoutDirs, 
	# 1.outs[:root] = File.join(@toolhome,@__ui__.out)
	# 2.outs[:logs] ...
	# 3.outs[:config] -> root dir of config
	# 4.outs[:component] -> root dir of components
	def _initoutDirs; ##{{{
		@outs={};
		@outs[:root]=File.join(@toolhome,@__ui__.options[:out]);
		tf=_timestamp();
		@outs[:logs]=File.join(@outs[:root],'logs',tf)
		#TODO, config, component paths
	end ##}}}

	## _initMaxVerbo(v), description
	def _initMaxVerbo(v); ##{{{
		@reportMaxVerbosity=v.to_i;
	end ##}}}
	## _initToolHome, description
	def _initToolHome; ##{{{
		#puts "#{__FILE__}:start _initToolHome ..."
		@toolhome=File.dirname(File.dirname(File.absolute_path(__FILE__)));
	end ##}}}
	## _initExecuteFlows, description
	def _initExecuteFlows; ##{{{
		#puts "#{__FILE__}:start _initExecuteFlows ..."
		@executeFlows = {};
		# setup the executeFlow according to input user commands.
		if @__ui__.options[:help]
			@executeFlows={'toolshow' => {:select=>:help,:message=>@__ui__.helpMessage}} ;
			return;
		end
		if @__ui__.options[:version]
			@executeFlows={'toolshow' => {:select=>:version}} ;
			return;
		end
		#@__ui__.commands.each_pair do |name,opts|
		#	if name==''
		#	@executeFlows={}
		#end
		Rsim.exception(UIE,:reason=>'no any command to be executed') unless @__ui__.command;
		Rsim.info(@__ui__.command[:name],5);
		# nomatter which command, nodeflow is always required
		@executeFlows['nodeflow']= {:entries=>_parseNodeEntry(@__ui__.options[:ROOT])}; 
		_setupBuildFlow;
		Rsim.info("executeFlows loaded (#{@executeFlows})",5);
		#TODO, more actions
		return;
	end ##}}}
	## _setupBuildFlow, description
	def _setupBuildFlow; ##{{{
		#puts "#{__FILE__}:start _setupBuildFlow ..."
		loading = false;
		loading = true if @__ui__.command[:name]=='buildflow';
		loading = true if @__ui__.command[:name]=='runflow' and (not @__ui__.skipped?('buildflow'));
		if (loading)
			opts={};
			opts[:config]= @__ui__.command[:opts][:config] if @__ui__.command[:opts].has_key?(:config);
			opts[:test]  = @__ui__.command[:opts][:test] if @__ui__.command[:opts].has_key?(:test);
			@executeFlows['buildflow']= opts;
		end
	end ##}}}
	## _parseNodeEntry(eS), description
	def _parseNodeEntry(eS); ##{{{
		#puts "#{__FILE__}:start _parseNodeEntry(eS) ..."
		splitted=eS.split(';') or eS;
		Rsim.info("splitted entry #{splitted}");
		return splitted;
	end ##}}}
end ##}}}