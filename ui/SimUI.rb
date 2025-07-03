require 'optparse'
require_relative '../exceptions/uie'
require 'fileutils'

class SimUI
	attr :options

	attr_accessor :proj_home;
	attr_accessor :log_path;

	def initialize
		@verbosity = {:info => 5,:debug => 10}

		env_setup

		@options = {
			:max_jobs=>10,:debug_mode=>false,:log_file=>File.join(@proj_home,'simulator.log'),
			:debug_log_file=>File.join(@proj_home,'simulator_debug.log'),
			:out_home=>File.absolute_path(File.join(@proj_home,'out')),
			:simulator=>'vcs',
			:compile_only=>false,
			:run_only=>false,
			:include_dirs=>[],
			:source_files=>[]
		}
		setup_options
		@log_path = File.join(@options[:out_home],'logs')
	end

	def verbosity(type)
		return @verbosity[type]
	end

	def out_home
		return @options[:out_home]
	end
	
	def env_setup
		@proj_home = ENV['PROJ_HOME'] || File.expand_path('.')
	end

	def log_file
		return @options[:log_file]
	end

	def debug_log_file
		return @options[:debug_log_file]
	end

	def max_jobs
		return @options[:max_jobs]
	end

	def config_dir
		return @options[:config_dir]
	end

	def parse_command
		# Parse the flow command to extract parameters
		simulator=@options[:simulator];
		action='sim';
		action='compile_only' if @options[:compile_only];
		action='run_only' if @options[:run_only];
		action='clean_only' if @options[:clean_only];
		
		params = {
			simulator: simulator,
			action: action,
			testcase: @options[:testcase]
		}
		params.merge!(translate_user_options);
		return params;
	end

private
	def translate_user_options
		message="translate_#{@options[:simulator]}_options";
		return self.send(message);
	end
	
	def translate_vcs_options
		vcs_options = {};
		
		# Common options
		vcs_options[:filelist] = @options[:filelist] if @options[:filelist]
		#vcs_options[:include_dirs] = @options[:include_dirs] if @options[:include_dirs]
		vcs_options[:full64] = @options[:full64] if @options[:full64]
		
		# Compile options - direct strings from --comp_opt
		vcs_options[:vcs_comp_options] = @options[:comp_opt] if @options[:comp_opt]
		
		# Elaborate options - direct strings from --elab_opt
		vcs_options[:vcs_elab_options] = @options[:elab_opt] if @options[:elab_opt]
		
		# Simulation options - direct strings from --run_opt
		vcs_options[:vcs_run_options] = @options[:run_opt] if @options[:run_opt]
		
		return vcs_options;
	end

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

			opts.on("-j", "--jobs NUMBER", Integer, "Set maximum number of jobs") do |number|
				@options[:max_jobs] = number
			end

			opts.on("--config-dir DIR", String, "Specify configuration directory") do |dir|
				@options[:config_dir] = File.absolute_path(dir)
			end

			opts.on("-l", "--log FILE", String, "Specify log file name") do |file|
				@options[:log_file] = file
			end

			opts.on("-o", "--out HOME", String, "Specify output home directory") do |home|
				@options[:out_home] = File.absolute_path(home)
			end

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
			opts.on("--testname TEST", String, "Specify test name in testsuite/testname format") do |test|
				@options[:testname] = test
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

			opts.on("--include-dirs DIRS", String, "Comma-separated list of include directories") do |dirs|
				@options[:include_dirs] = dirs.split(',').map(&:strip)
			end

			opts.on("--source-files FILES", String, "Comma-separated list of source files") do |files|
				@options[:source_files] = files.split(',').map(&:strip)
			end

			opts.on("--full64", "Enable 64-bit mode") do
				@options[:full64] = true
			end

			opts.on("--debug", "Enable debug mode") do
				@options[:debug] = true
			end

			opts.on("--verbose", "Enable verbose output") do
				@options[:verbose] = true
			end
			opts.on("--testcase TEST", String, "Specify test name in testsuite/testname format") do |test|
				@options[:testcase] = test
			end
		end.parse!
	end
end 