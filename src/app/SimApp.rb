require 'mjs'
require_relative '../exceptions/uie'
require_relative '../exceptions/ipxe'
require_relative 'ReportApi'

require_relative '../ui/SimUI'
require_relative '../builders/VcsSimulator'
require_relative '../ipxact/database'

class SimApplication
	attr_accessor :ui
	attr_accessor :pm

	attr :meta;

	def initialize
		@ui = SimUI.new()

		SimApp.info("setting verbosity overrides")
		SimApp.printer.set_verbosity(@ui.verbosity(:info))
		SimApp.debugger.set_verbosity(@ui.verbosity(:debug))
		SimApp.debugger.enable(@ui.options[:debug_mode])

		SimApp.printer.open_log(@ui.log_file);
		SimApp.debugger.open_log(@ui.debug_log_file);

		@meta = MetaDatabase.new(@ui.options[:out_dir],SimApp,false)
		@meta.read_from_xml;

		SimApp.debug("SimApplication initialized", 5)
	end

	def setup_sim_options(simulator)
		simulator = simulator.to_sym;
		s=@meta.find_suite(@ui.options[:suite],:use_name=>true);
		t=s.get_testcase(@ui.options[:testname]);
		c=@meta.find_config(t.config_name,:use_name=>true);
		@ui.options[:comp_opt].append(*c.compile_options[simulator]);
		@ui.options[:elab_opt].append(*c.elaborate_options[simulator]);
		@ui.options[:run_opt].append(*t.run_args);
		setup_filelist(t.config_name) unless @ui.options[:filelist]
		@ui.options[:root_dir] = File.join(@ui.options[:out_dir],'build/configs',t.config_name)
	end
	def setup_filelist(config_name)
		@ui.options[:filelist] = File.join(@ui.options[:out_dir],'build/configs',config_name,'filelist.f')
		SimApp.info("Setting up filelist for config(#{config_name}): #{@ui.options[:filelist]}", 6)
	end

	def run
		SimApp.debug("SimApplication running", 5)
		setup_sim_options(@ui.options[:simulator])
		execute_simulation
		# finish the application.
		SimApp.debug("SimApplication finished", 5)
		SimApp.printer.close;
	end

	def execute_simulation
		SimApp.debug("Executing simulation with options: #{@ui.options}", 5)
		
		simulator_type = @ui.options[:simulator];
		action = @ui.action;
		if (action == 'run_only' || action == 'sim') && !@ui.options[:testname]
			raise UIException, "Testname must be specified when action is 'run_only' or 'sim'"
		end

		case simulator_type.downcase
		when 'vcs'
			execute_vcs_simulation
		when 'xcelium'
			execute_xcelium_simulation
		else
			raise UIException, "Unsupported simulator: #{simulator_type}"
		end
	end

	def execute_xcelium_simulation
		SimApp.info("Executing Xcelium simulation")
		raise UIException, "Xcelium simulation not implemented"
	end

	def execute_vcs_simulation
		SimApp.info("Executing VCS simulation")
		
		# Create VCS simulator instance
		vcs_params = {
			remote: @ui.options[:remote],
			out_dir: @ui.options[:root_dir],
			filelist: @ui.options[:filelist],
			compile_options: @ui.options[:comp_opt]&.join(' ') || '',
			elaborate_options: @ui.options[:elab_opt]&.join(' ') || '',
			run_options: @ui.options[:run_opt]&.join(' ') || '',
			full64: @ui.options[:full64] || false,
			debug: @ui.options[:debug_mode] || false,
			verbose: @ui.options[:verbose] || false,
			run_dir: File.join(@ui.options[:root_dir],'run',@ui.options[:suite],@ui.options[:testname]),
		}
		
		eda = VcsSimulator.new(vcs_params)
		
		# Execute based on action
		case @ui.action
		when 'compile_only'
			eda.compile
			eda.elaborate
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