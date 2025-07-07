require 'mjs'
require_relative '../exceptions/uie'
require_relative '../exceptions/ipxe'
require_relative 'ReportApi'

require_relative '../ui/SimUI'
require_relative '../builders/VcsSimulator'

class SimApplication
	attr_accessor :ui
	attr_accessor :pm

	def initialize
		@ui = SimUI.new()

		SimApp.info("setting verbosity overrides")
		SimApp.printer.set_verbosity(@ui.verbosity(:info))
		SimApp.debugger.set_verbosity(@ui.verbosity(:debug))
		SimApp.debugger.enable(@ui.options[:debug_mode])

		SimApp.printer.open_log(@ui.log_file);
		SimApp.debugger.open_log(@ui.debug_log_file);

		SimApp.debug("SimApplication initialized", 5)
	end

	def run
		SimApp.debug("SimApplication running", 5)
		params = @ui.parse_command; # parse the flow command given by -e
		self.execute_simulation(params)

		# finish the application.
		SimApp.debug("SimApplication finished", 5)
		SimApp.printer.close;
	end

	def execute_simulation(params)
		SimApp.debug("Executing simulation with params: #{params}", 5)
		
		simulator_type = params[:simulator];
		action = params[:action] || 'sim'
		if (action == 'run_only' || action == 'sim') && !params[:testcase]
			raise UIException, "Testcase must be specified when action is 'run_only' or 'sim'"
		end

		case simulator_type.downcase
		when 'vcs'
			execute_vcs_simulation(params)
		else
			raise UIException, "Unsupported simulator: #{simulator_type}"
		end
	end

	def execute_vcs_simulation(params)
		SimApp.info("Executing VCS simulation")
		
		# Create VCS simulator instance
		vcs_params = {
			out_dir: @ui.config_dir,
			filelist: params[:filelist],
			compile_options: params[:vcs_comp_options]&.join(' ') || '',
			elaborate_options: params[:vcs_elab_options]&.join(' ') || '',
			run_options: params[:vcs_run_options]&.join(' ') || '',
			full64: params[:full64] || false,
			debug: params[:debug] || false,
			verbose: params[:verbose] || false,
			testcase: params[:testcase]
		}
		
		eda = VcsSimulator.new(vcs_params) if params[:simulator] == 'vcs';
		eda = XceliumSimulator.new(vcs_params) if params[:simulator] == 'xcelium';
		raise UIException, "Unsupported simulator: #{params[:simulator]}" if eda.nil?;
		
		# Execute based on action
		case params[:action]
		when 'compile_only'
			eda.compile
		when 'run_only'
			eda.run
		when 'clean_only'
			eda.clean
		else
			# Default: full simulation flow
			eda.compile
			eda.elaborate
			eda.run
		end
	end
end

module SimApp extend ReportApi
	@@app = nil
	@generators = {};

	def self.register_generator(generator)
		@generators[generator.name.to_s] = generator;
	end

	def self.generator(name=nil)
		return @generators[name.to_s] if name and @generators.has_key?(name.to_s);
		return nil;
	end

	def self.ui
		return @@app.ui
	end

	# the multiple job system
	def self.mj
		return MultJobSystem;
	end

	def self.pm
		return @@app.pm;
	end

	def self.init
		SimApp.debug("Printer verbosity: #{SimApp.printer.verbosity}", 5)
		SimApp.debug("Debugger verbosity: #{SimApp.debugger.verbosity}", 5)

		@@app = SimApplication.new() if @@app.nil?;

		# init mjs system.
		MultJobSystem.run(@@app.ui.max_jobs,10,@@app.ui.log_path);

		self.debug("SimApp initialized", 5)
	end

	def self.run
		@@app.run;
	end
end 