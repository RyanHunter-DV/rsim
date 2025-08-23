require 'optparse'

class NlUi
	attr_accessor :options
	
	def initialize
		@options = {}
		setup_default_options
		setup_user_options
	end

	def out_home
		return @options[:out_dir]
	end

	def log_file
		return File.join(@options[:out_dir], 'logs','node_load.log')
	end
	def debug_log_file
		return File.join(@options[:out_dir], 'logs','node_load_debug.log')
	end

	def node_entries
		return @options[:entries]
	end

	def verbosity(severity)
		return @options[:verbosity][severity.to_sym]
	end
	def setup_user_options
		OptionParser.new do |opts|
			opts.banner = "Usage: node_load [options]"
			
			opts.on("-h", "--help", "Show this help message") do
				puts opts
				exit
			end
			
			opts.on("-v", "--version", "Show version information") do
				puts "nlui version 1.0.0"
				exit
			end
			opts.on("--entry ENTRY", "Add node entry") do |entry|
				@options[:entries] ||= []
				@options[:entries] << File.absolute_path(entry)
			end
			
			opts.on("--out DIR", "Specify output directory") do |dir|
				@options[:out_dir] = dir
			end
			opts.on("--verbosity LEVEL", "Set verbosity level") do |v|
				@options[:verbosity][:info] = v.to_i
			end

			opts.on("-d", "--debug LEVEL", "Enable debug mode") do |v|
				@options[:verbosity][:debug] = v.to_i
				@options[:debug_mode] = true
			end
		end.parse!
	end

	def setup_default_options
		@options[:out_dir] = 'out'
		@options[:debug_mode] = false
		@options[:entries] = []
		@options[:verbosity] = {:info=>5,:debug=>9};
	end
end
