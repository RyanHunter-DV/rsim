"""
# Object description:
UserInterface, description
"""
require 'optparse'
class UserInterface ##{{{
	attr :maxJobs; # maximum parallel jobs the tool can issue.
	attr :envs;
	attr :outs;
	attr :execute;

	attr_accessor :maxVerbo;
	## initialize, description
	def initialize; ##{{{
		checkCriticalEnvVars;
		initToolOptionsByDefault;
		processUserOptions;
	end ##}}}

	## hackCriticalEnvVars, description
	def hackCriticalEnvVars; ##{{{
		ENV['RSIM_ROOT']='./';
		ENV['RSIM_ENTRIES']='./root.rh';
	end ##}}}

	## checkCriticalEnvVars, 
	# RSIM_ENTRIES, must has at least one entry.
	# RSIM_ROOT, the root workarea.
	def checkCriticalEnvVars; ##{{{
		@envs={};
		hackCriticalEnvVars if $TAG==:develop;
		vars=['RSIM_ENTRIES','RSIM_ROOT'];
		reason='critical env($ENV_VAR) not detected';
		vars.each do |varname|
			if ENV[varname]
				@envs[varname]=ENV[varname];
			else
				replaced=reason.sub(/ENV_VAR/,varname) 
				raise FatalE.new(replaced,:display);
			end
		end
	end ##}}}
	## initToolOptionsByDefault, set default tool options
	def initToolOptionsByDefault; ##{{{
		# outs are all dirs related to output targets, such as
		# outs[:logdir], the root log dir stores all log files
		# outs[:logs][:root], the root log dir stores all log files.
		# outs[:logs][:main], the tool log filename.
		@outs={
			:root=>updateOutHome('out'), # the root out path.
			:logs=>{
				:root=>'logs', # the log home dir name, not the full path.
				:main=>'rsim.log', # the main tool log file name.
			},
		};
		@maxVerbo=5;
		@maxJobs=1;
	end ##}}}
	## updateOutHome(n), description
	def updateOutHome(n); ##{{{
		_outHome=File.absolute_path(File.join(@envs['RSIM_ROOT'],n));
		return _outHome;
	end ##}}}
	## processUserOptions, use option parser
	def processUserOptions; ##{{{
		OptionParser.new() do |opts|
			opts.on('-v','--verbo=VERBO','set verbosity for report') do |v|
				@maxVerbo=v.to_i;
			end
			opts.on('-e','--exe=COMMAND','set user execute command') do |v|
				# examples
				# -e 'build(:ConfigName)', to build a specific config
				@execute=v;
			end
			opts.on('-o','--out=DIR','specify a new out dir instead of the default') do |v|
				@outs[:root]= updateOutHome(v);
			end
		end.parse!
	end ##}}}

	## mainlog, returns the log file name of the rsim tool
	def mainlog; ##{{{
		return @outs[:logs][:main];
	end ##}}}
	## outhome, returns the home path of the out
	def outhome; ##{{{
		return @outs[:root];
	end ##}}}
	## loghome, returns the log home dir, with full path
	def loghome; ##{{{
		return File.join(@outs[:root],@outs[:logs][:root]);
	end ##}}}
	## entries, return the entries env var
	# this env variable is critical env, which must exists.
	def entries; ##{{{
		return @envs['RSIM_ENTRIES']
	end ##}}}
end ##}}}