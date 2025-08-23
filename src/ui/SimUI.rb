require 'optparse'
require_relative '../exceptions/uie'
require 'fileutils'

class SimUI

	attr_accessor :options
	attr_accessor :action;

	attr :log_file;
	def initialize
		@verbosity = {:info => 5,:debug => 10}

		init_default_options
		setup_options
		determine_action;
	end

	def init_default_options
		@options = {
			:remote=>false,
			:full64=>true,
			:max_jobs=>10,:debug_mode=>false,
			:log_file=>nil,
			:root_dir=>nil,
			:out_dir=>nil,
			:suite=>nil,
			:filelist=>nil,
			:testname=>nil,
			:comp_opt=>[],
			:elab_opt=>[],
			:run_opt=>[],
			:simulator=>'vcs',
			:compile_only=>false,
			:run_only=>false,
		};
	end

	def verbosity(type)
		return @verbosity[type]
	end

	def log_path
		return File.join(@options[:out_dir], 'logs')
	end
	def log_file
		return File.join(log_path, 'simulator.log')
	end
	def debug_log_file
		return File.join(log_path, 'simulator_debug.log')
	end

	def max_jobs
		return @options[:max_jobs]
	end

	def determine_action
		# Parse the flow command to extract parameters
		@action='sim';
		@action='compile_only' if @options[:compile_only];
		@action='run_only' if @options[:run_only];
		@action='clean_only' if @options[:clean_only];
	end

private
	#def translate_user_options
	#	message="translate_#{@options[:simulator]}_options";
	#	return self.send(message);
	#end

	#not used, def translate_vcs_options
	#not used, 	vcs_options = {};
	#not used, 	
	#not used, 	# Common options
	#not used, 	vcs_options[:filelist] = @options[:filelist] if @options[:filelist]
	#not used, 	#vcs_options[:include_dirs] = @options[:include_dirs] if @options[:include_dirs]
	#not used, 	vcs_options[:full64] = @options[:full64] if @options[:full64]
	#not used, 	
	#not used, 	# Compile options - direct strings from --comp_opt
	#not used, 	vcs_options[:compile_options] = @options[:comp_opt] if @options[:comp_opt]
	#not used, 	
	#not used, 	# Elaborate options - direct strings from --elab_opt
	#not used, 	vcs_options[:elaborate_options] = @options[:elab_opt] if @options[:elab_opt]
	#not used, 	
	#not used, 	# Simulation options - direct strings from --run_opt
	#not used, 	vcs_options[:run_options] = @options[:run_opt] if @options[:run_opt]
	#not used, 	
	#not used, 	return vcs_options;
	#not used, end

	def setup_options
		OptionParser.new do |opts|
			opts.banner = "Usage: simulator [options]"

			opts.on("-v", "--verbose LEVEL", Integer, "Set verbose level (0-10)") do |level|
				@verbosity[:info] = level
			end

			opts.on("-d", "--debug [LEVEL]", Integer, "Set debug level (0-10)") do |level|
				@verbosity[:debug] = level || 10
				@options[:debug_mode] = true
			end

			opts.on("-h", "--help", "Show this help message") do
				puts opts
				puts "Using example:"
				puts " --simulator vcs --compile-only --source-files file1.sv,file2.sv"
				exit
			end

			#TODO, currently not used, opts.on("-j", "--jobs NUMBER", Integer, "Set maximum number of jobs") do |number|
			#TODO, currently not used, 	@options[:max_jobs] = number
			#TODO, currently not used, end

			opts.on("--out-dir DIR", String, "Specify the output directory, where the command will be built") do |dir|
				# attention that the sim dir is <root_dir>/run/<suitename>/<testname>/
				@options[:out_dir] = File.absolute_path(dir)
			end
			#opts.on("--root-dir DIR", String, "Specify the root directory, where the command will be built") do |dir|
			#	# attention that the sim dir is <root_dir>/run/<suitename>/<testname>/
			#	@options[:root_dir] = File.absolute_path(dir)
			#end
			# the testname is of format: testsuite/testname
			opts.on("--testname TEST", String, "Specify test name in testsuite/testname format") do |test|
				if test.include?('/')
					suite, tname = test.split('/', 2)
					@options[:suite] = suite
					@options[:testname] = tname
				else
					raise UIException, "Test name must be in 'testsuite/testname' format"
				end
			end

			opts.on("-l", "--log FILE", String, "Specify log file name") do |file|
				@options[:log_file] = file
			end

			#TODO, not used, opts.on("-o", "--out HOME", String, "Specify output home directory") do |home|
			#TODO, not used, 	@options[:out_home] = File.absolute_path(home)
			#TODO, not used, end

			opts.on("-s", "--skip ITEMS", String, "Skip generators, chain_selectors, or flows") do |items|
				# Skip functionality removed - kept for compatibility
			end

			opts.on("--comp_opt OPTIONS", String, "Specify EDA compilation options") do |options|
				@options[:comp_opt]=[] unless @options[:comp_opt]
				@options[:comp_opt] << options
			end
			opts.on("--elab_opt OPTIONS", String, "Specify EDA elaboration options") do |options|
				@options[:elab_opt]=[] unless @options[:elab_opt]
				@options[:elab_opt] << options
			end
			opts.on("--run_opt OPTIONS", String, "Specify EDA simulation options") do |options|
				@options[:run_opt]=[] unless @options[:run_opt]
				@options[:run_opt] << options
			end

			# Simulator-specific options
			opts.on("--simulator SIM", String, "Specify simulator (vcs, xcelium, modelsim)") do |sim|
				@options[:simulator] = sim
			end

			opts.on("--compile-only", "Only compile, skip elaborate and run") do
				@options[:compile_only] = true
			end

			opts.on("--run-only", "Only run, skip compile and elaborate") do
				@options[:run_only] = true
			end

			opts.on("--clean-only", "Only clean simulation files") do
				@options[:clean_only] = true
			end

			opts.on("--filelist FILE", String, "Specify filelist file") do |file|
				@options[:filelist] = file
			end

			opts.on("--full64", "Enable 64-bit mode") do
				@options[:full64] = true
			end
			opts.on("-r", "--remote", "Enable remote job execution") do
				@options[:remote] = true
			end
		end.parse!
	end
end 