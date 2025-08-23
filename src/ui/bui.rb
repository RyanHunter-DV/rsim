class BuilderUi
	attr_accessor :options
	attr_accessor :verbosity
	attr_accessor :log_file
	attr_accessor :debug_log_file

	attr_accessor :out_home;
	def initialize
		@options = {}
		@out_home = ENV['OUT_HOME']
		@log_file = File.join(@out_home,'logs','rtl.log')
		@debug_log_file = File.join(@out_home,'logs','rtl_debug.log')
		setup_default_options
		setup_options
		check_user_options
	end

	def verbosity(type)
		return @options[:verbosity][type.to_sym]
	end

	def setup_default_options
		@out_home = './out' if @out_home.nil?

		@options[:debug_mode] = false
		@options[:verbosity] = {:info=>0,:debug=>0}
		@options[:log_file] = File.join(ENV['OUT_HOME'],'logs','builder.log')
		@options[:debug_log_file] = File.join(ENV['OUT_HOME'],'logs','builder_debug.log')
		@options[:build_mode] = :rtl
		@options[:out_home] = nil
		@options[:config] = nil
		@options[:method] = :link;
	end
	def check_user_options
		raise UIException.new("--out option must be specified") if @options[:out_home].nil?
		raise UIException.new("--config option must be specified") if @options[:config].nil?
	end

	def setup_options
		require 'optparse'

		OptionParser.new do |opts|
			opts.banner = "Usage: builder [options]"

			opts.on("-d", "--debug LEVEL", Integer, "Set debug level (0-10)") do |level|
				@options[:debug_mode] = true
				@options[:verbosity][:debug] = level;
			end
			opts.on("-v", "--verbose LEVEL", Integer, "Set verbose level (0-10)") do |level|
				@options[:verbosity][:info] = level;
			end

			opts.on("-l", "--log-file FILE", "Specify log file path") do |file|
				@options[:log_file] = file
			end

			opts.on("--debug-log-file FILE", "Specify debug log file path") do |file|
				@options[:debug_log_file] = file
			end

			opts.on("--rtl", "Build in RTL mode") do
				@options[:build_mode] = :rtl
			end

			opts.on("--dv", "Build in DV mode") do
				@options[:build_mode] = :dv
			end

			opts.on("--out DIR", "Specify the meta database directory") do |dir|
				@options[:out_home] = dir
			end

			opts.on("--config NAME", "Specify the config name") do |name|
				@options[:config] = name
			end
			opts.on("--method NAME", "Specify the building method") do |name|
				@options[:method] = name
			end

			opts.on("-h", "--help", "Show this help message") do
				puts opts
				exit
			end
		end.parse!
	end



end