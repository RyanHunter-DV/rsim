require_relative 'ReportApi'
require_relative '../ui/bui'
require_relative '../ipxact/init'
require_relative '../ipxact/xmls/init'
require_relative '../exceptions/uie'
require_relative '../exceptions/ipxe'
require_relative '../builders/init'

require 'fileutils'

class Application
	attr_accessor :ui
	attr_accessor :loader
	attr_accessor :meta

	def initialize
		#1.init ui
		#2.setup reporter
		#3.according to user selected builder, to init builder
		@ui = BuilderUi.new()

		BuildApp.info("setting verbosity overrides")
		BuildApp.printer.set_verbosity(@ui.verbosity(:info))
		BuildApp.debugger.set_verbosity(@ui.verbosity(:debug))
		BuildApp.debugger.enable(@ui.options[:debug_mode])
		BuildApp.printer.open_log(@ui.log_file);
		BuildApp.debugger.open_log(@ui.debug_log_file);

		@meta = MetaDatabase.new(@ui.options[:out_home],BuildApp)
		#4.init builder
		@builder = Builder.new(@ui,BuildApp)


		BuildApp.debug("Application initialized", 5)
	end

	def create_dir(path)
		FileUtils.mkdir_p(path) unless Dir.exist?(path)
	end

	def run
		BuildApp.info("Application running", 5)
		@meta.read_from_xml;
		config = @meta.find_by_name(:config,@ui.options[:config]);
		config.design(@meta.find(:design,config.designRef));
		config.needs.each do |instance_name|
			BuildApp.info("Building component: #{instance_name}", 5)
			#1.to run the corresponding builder.
			# according to component's information, such like:
			# the component's instance name,
			c= @meta.find(:component,config.find_component_name(instance_name));
			view_name=config.find_component_view_name(instance_name)
			#file_sets = config.find_component_file_sets(instance_name)
			# the component file_sets
			@builder.build_component(c,view_name)
		end
		@builder.build_config(config);

		BuildApp.info("Application finished", 5)
		BuildApp.printer.close;
	end
end

module BuildApp extend ReportApi
	@@app = nil

	def self.init
		#1.initialize the global app object by new the Application
		@@app = Application.new
	end

	def self.run
		@@app.run
	end
end
