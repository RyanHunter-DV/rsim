require 'mjs'
require_relative '../exceptions/uie'
require_relative '../exceptions/ipxe'
require_relative 'ReportApi'

require_relative '../ui/UI'
require_relative '../ipxact/generator/init'
class Application
	attr_accessor :ui
	attr_accessor :pm

	def initialize
		@ui = UI.new()

		RsApp.info("setting verbosity overrides")
		RsApp.printer.set_verbosity(@ui.verbosity(:info))
		RsApp.debugger.set_verbosity(@ui.verbosity(:debug))
		RsApp.debugger.enable(@ui.options[:debug_mode])

		create_dir(@ui.out_home);
		create_dir(File.join(@ui.out_home,'logs'));
		RsApp.printer.open_log(@ui.log_file);
		RsApp.debugger.open_log(@ui.debug_log_file);

		# 2. node loading

		RsApp.debug("Application initialized", 5)
	end
	def create_dir(path)
		FileUtils.mkdir_p(path) unless File.directory?(path)
	end

	def run
		RsApp.debug("Application running", 5)
		@ui.parse_command; # parse the flow command given by -e
		self.chain_execute(@ui.chain)

		# finish the application.
		RsApp.debug("Application finished", 5)
		RsApp.printer.close;
	end

	def chain_execute(chain)
		RsApp.debug("Executing chain: #{chain[:name]}", 5)
		#TODO
		# main process to get the chain.rb, translated to object. then call the executor?
		# require an object that can parse to generator xml or read from generator xml.
		# the generator and generator chains are pre-defined tools and flows located in flows/ 
		unless RsApp.chains.has_key?(chain[:name])
			raise UIException, "Chain '#{chain[:name]}' not defined"
		end
		RsApp.debug("Chain params: #{chain[:params]}", 5)
		RsApp.chains[chain[:name]].execute(chain[:params]);
	end
end


module RsApp extend ReportApi
	#@printer = nil
	#@debugger = nil
	@@app = nil
	@root_dir = nil;
	@chains = {};
	@generators = {};

	def self.chain(name=nil)
		return @chains[name.to_s] if name and @chains.has_key?(name.to_s);
		return nil;
	end
	def self.chains
		return @chains;
	end
	def self.register_chain(chain)
		@chains[chain.name.to_s] = chain;
	end
	def self.register_generator(generator)
		@generators[generator.name.to_s] = generator;
	end
	def self.generator(name=nil)
		return @generators[name.to_s] if name and @generators.has_key?(name.to_s);
		return nil;
	end
	def self.root_dir
		return @root_dir;
	end
	#def self.printer
	#	return @printer;
	#end
	#def self.debugger
	#	return @debugger;
	#end
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
		@root_dir = File.absolute_path(File.join(File.dirname(__FILE__),'..'));
		# 1.init the printer and debugger.
		#ReportApi.init_reporter
		RsApp.debug("Printer verbosity: #{RsApp.printer.verbosity}", 5)
		RsApp.debug("Debugger verbosity: #{RsApp.debugger.verbosity}", 5)

		@@app = Application.new() if @@app.nil?;

		# init mjs system.
		MultJobSystem.run(@@app.ui.max_jobs,10,@@app.ui.log_path);

		self.debug("RsApp initialized", 5)
	end

	def self.run
		require_relative '../chains/init'
		@@app.run;
	end

	#def self.info(message, verbo=5)
	#	if @printer.nil?
	#		puts "[RAW] #{message}"
	#	else
	#		@printer.write(message, verbo,1)
	#	end
	#end

	#def self.debug(message, verbo=5)
	#	if @debugger.nil?
	#		puts "[RAW] #{message}"
	#	else
	#		@debugger.write(message, verbo,1)
	#	end
	#end

end