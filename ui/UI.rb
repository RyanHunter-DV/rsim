require 'optparse'
require_relative '../exceptions/uie'
require 'fileutils'

class UI
	attr :options

	attr_accessor :proj_home;
	attr :flow_command;
	attr_accessor :chain;
	attr_accessor :log_path;

	def initialize
		@verbosity = {:info => 5,:debug => 10}

		env_setup

		@options = {
			:max_jobs=>10,:debug_mode=>false,:log_file=>File.join(@proj_home,'rsim.log'),
			:debug_log_file=>File.join(@proj_home,'rsim_debug.log'),
			:out_home=>File.absolute_path(File.join(@proj_home,'out'))
		}
		@chain = {:name=>nil,:skip =>[],:params =>{} }
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


	def parse_chain_command
		# Parse the flow command to extract chain name and parameters
		# option example:
		# -e simflow -s build,compile... -p '--eda vcs --config config_name'
		# -e buildflow -p '--config config_name'
		# the -p is the chain parameters, it can also be specified by a config.
		# all -s options will be arranged to a skip list and then to return a hash that has chain executing operations.
		# which will be called by app.chain_execute
		# the hash has the following format:
		# {
		#   :chain_name => {
		#     :skip => [skip_list],
		#     :execute => [execute_list]
		#   } Format: chain_name(param1,param2,...) or just chain_name
		@chain[:name]=@flow_command.to_s;
	end

	def parse_command
		raise UIException.new("-e must specified to execute a chain") if @flow_command.nil?;
		parse_chain_command
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
				puts "Using example:"
				puts " -e sim -s build,compile... -p '--eda vcs --config config_name'"
				puts " -e build -p '--config config_name'"
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
			opts.on("-s", "--skip ITEMS", String, "Skip generators, chain_selectors, or flows") do |items|
				if items.include?(',')
					items.split(',').each do |item|
						@chain[:skip] << item.strip
					end
				else
					@chain[:skip] << items.strip
				end
			end
			opts.on("-p", "--param PARAMS", String, "Add parameters to chain command") do |params|
				# format: -p 'name = value'
				if params.include?('=')
					name, value = params.split('=', 2)
					@chain[:params][name.strip.to_s] = value.strip
				else
					name, value = params.split(' ')
					@chain[:params][name.strip.to_s] = value.strip
				end
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
		end.parse!
	end

end