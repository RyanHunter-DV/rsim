require 'optparse'
require_relative '../exceptions/uie'
require 'fileutils'

class UI
	attr :options

	attr_accessor :flows, :proj_home;

	attr :flow_command;
	attr :flow_options;
	attr :flow_option_format;


	def initialize
		@verbosity = {:info => 5,:debug => 10}

		env_setup

		@options = {
			:max_jobs=>10,:debug_mode=>false,:log_file=>File.join(@proj_home,'rsim.log'),
			:debug_log_file=>File.join(@proj_home,'rsim_debug.log'),
			:out_home=>File.absolute_path(File.join(@proj_home,'out'))
		}
		@flows = {}; @flow_command = nil;
		setup_options
		@flow_options_formats = {};
		@flow_options = {};
		
	end

	def verbosity(type)
		return @verbosity[type]
	end
	def out_home
		return @options[:out_home]
	end
	
	def env_setup
		@proj_home = ENV['PROJ_HOME']
		raise UIException.new("ENV 'PROJ_HOME' required and not set") if @proj_home.nil? || @proj_home.empty?
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

	# ui :rsim_entry,:type => :string,:description => "rsim root.rh file as the entry of buildflow"
	def add_option(name,opts)
		name_s=name.to_s;
		formats={
			:short=>"-#{opts[:flow_name][0]}#{name_s[0]}",
			:description=>opts[:description],
			:long=>opts[:type] == :switch ? "--#{opts[:flow_name]}-#{name_s}" : "--#{opts[:flow_name]}-#{name_s}=#{name_s.upcase}",
			:type=>opts[:type]
		};
		@flow_options_formats[name] = formats;
	end
	def parse_flow_options
		OptionParser.new do |opts|
			@flow_options_formats.each do |name,formats|
				RsApp.debug("Setting up flow option: #{name} with formats: #{formats}", 8)
				opts.on(formats[:short],formats[:long],formats[:description]) do |value|
					if formats[:type] == :string
						@flow_options[name] = value
					elsif formats[:type] == :array
						@flow_options[name] << value;
					elsif formats[:type]==:switch
						@flow_options[name] = true;
					end
				end
			end
			opts.on("-fh", "--flow-help", "Show flow options help message") do
				puts opts
				exit
			end
		end.parse!
	end

	def parse_command
		raise UIException.new("Flow command cannot be empty") if @flow_command.nil?;
		# Parse the flow command to extract flow name and options
		# Expected format: flowname(options)
		if @flow_command =~ /^(\w+)\((.*)\)$/
			flow_name = $1.to_sym
			flow_options_str = $2
			
			# Store the flow as a hash with flow_name as key and options string as value
			@flows[flow_name] = flow_options_str
			
			RsApp.debug("Parsed flow command: name=#{flow_name}, options=#{flow_options_str}", 5)
		else
			raise UIException.new("Invalid flow command format. Expected: flowname(options)")
		end
	end
private

	def setup_options
		OptionParser.new do |opts|
			opts.banner = "Usage: rsim [options]"

			opts.on("-v", "--verbose LEVEL", Integer, "Set verbose level (0-10)") do |level|
				@verbosity[:info] = level
			end

			opts.on("-d", "--debug [LEVEL]", Integer, "Set debug level (0-10)") do |level|
				@verbosity[:debug] = level || 10
				@options[:debug_mode] = true
			end
			opts.on("-h", "--help", "Show this help message") do
				puts opts
				exit
			end
			opts.on("-j", "--jobs NUMBER", Integer, "Set maximum number of jobs") do |number|
				@options[:max_jobs] = number
			end
			opts.on("-l", "--log FILE", String, "Specify log file name") do |file|
				@options[:log_file] = file
			end
			opts.on("-o", "--out HOME", String, "Specify output home directory") do |home|
				@options[:out_home] = File.absolute_path(home)
			end

			# options for the flow command, for example:
			# -e 'buildflow(:config)'
			# -e 'simflow(suite/testname)'
			opts.on("-e", "--flow COMMAND", String, "Execute a flow command") do |command|
				# here's the raw string for flow command, which will be parsed by ui.parse_command
				# and then can generate the list of @flows
				@flow_command = command;
				#TODO, the UIE not defined yet, the calling format may need change later.
				raise UIException.new("Flow command cannot be empty") if command=='';
			end
			# option -s can be used to skip certain actions, steps of a flow, or even to skip flows.
			# examples:
			# to skip a step(s) or action(s) of a flow:
			# -s buildflow-step1,step2,action1,action2,...
			# attention that the step name and action name in same flow must not be the same.
			# to skip a flow:
			# -s buildflow
			# multiple -s option are supported to collect multiple skips.
			#TODO
		end.parse!
	end

end