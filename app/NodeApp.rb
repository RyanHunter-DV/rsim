require_relative 'ReportApi'
require_relative '../ui/nlui'
require_relative '../ipxact/init'
require_relative '../ipxact/global_def'
require_relative '../loaders/init'
require_relative '../exceptions/uie'
require_relative '../exceptions/ipxe'

require 'fileutils'

class Application
	attr_accessor :ui
	attr_accessor :loader
	attr_accessor :meta

	def initialize
		@ui = NlUi.new()

		NodeApp.info("setting verbosity overrides")
		NodeApp.printer.set_verbosity(@ui.verbosity(:info))
		NodeApp.debugger.set_verbosity(@ui.verbosity(:debug))
		NodeApp.debugger.enable(@ui.options[:debug_mode])


		create_dir(@ui.out_home);
		create_dir(File.join(@ui.out_home,'logs'));
		NodeApp.printer.open_log(@ui.log_file);
		NodeApp.debugger.open_log(@ui.debug_log_file);

		@meta = MetaDatabase.new(@ui.out_home,NodeApp);
		@loader=LoadM.new;

		NodeApp.debug("Application initialized", 5)
	end

	def create_dir(path)
		FileUtils.mkdir_p(path) unless Dir.exist?(path)
	end

	def run
		NodeApp.info("Application running", 5)

		@ui.node_entries.each do |entry|
			NodeApp.info("Loading root node: #{entry}", 5)
			@loader.load_node(entry)
		end

		NodeApp.info("Application finished", 5)
		NodeApp.printer.close;
	end


end


module NodeApp extend ReportApi
	@@app = nil;

	def self.init
		NodeApp.info("NodeApp.init", 5)
		@@app = Application.new() if @@app.nil?;
	end

	def self.run
		NodeApp.debug("NodeApp.run", 5)
		@@app.run
	end

	def self.loader
		@@app.loader
	end

	def self.meta
		@@app.meta
	end
end