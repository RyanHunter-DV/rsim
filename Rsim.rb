require 'ui/entry'
require 'os/entry'
require 'libs/MessageReport.rb'
require 'exceptions/entry'
require 'ipxact/entry'
module Rsim

	@os=nil;@report=nil;
	@ipxact=nil;@ui=nil;

	@loadContext=nil; # current loading context
	@node={}; # current loading node file

	FINTERNAL = 1;

	## self.loadContext(c=nil), description
	def self.loadContext(o=nil); ##{{{
		#puts "#{__FILE__}:start self.loadContext(c=nil) ..."
		return @loadContext unless o;
		@loadContext=o;
	end ##}}}

	## self.exception(et,**opts), raise an exception
	# et -> the exception object
	# opts:
	# [:reason], reason to raise the exception.
	# [:exit], to exit immediately or not ,default is true
	def self.exception(et,**opts); ##{{{
		#puts "#{__FILE__}:start self.exception(et,**opts) ..."
		opts[:stack]=caller(0).join("\n");
		e=et.new(**opts);
		raise e;
	end ##}}}
	## self.report, description
	def self.report(); ##{{{
		return @report unless @report==nil;
		puts "FATAL, report not correctly initialized before using";
		puts caller(1);
		exit -1;
	end ##}}}
	## self.info(msg,verbo=2), description
	# when report ready, use @report.info.
	# when report is not ready, use puts
	def self.info(msg,verbo=2,depth=1); ##{{{
		if @report
			self.report.info(msg,depth,verbo);
		else
			puts "[RAW@#{caller(1)[0]}] #{msg}";
		end
	end ##}}}

	## self.os, description
	def self.os; ##{{{
		self.report.fatal(FINTERNAL,"os is referenced before initialized") unless @os;
		return @os;
	end ##}}}

	## self.ipxact, return the ipxact object
	def self.ipxact ##{{{
		self.report.fatal(FINTERNAL,'ipxact referenced before initialized') unless @ipxact;
		return @ipxact;
	end ##}}}
	## self.ui, description
	def self.ui ##{{{
		self.report.fatal(FINTERNAL,'ui referenced before initialized') unless @ui;
		return @ui;
	end ##}}}

	## self.init, tool initialization
	def self.init; ##{{{
		# 1.ui processing
		@ui=UI.new;
		# 2.init os system
		@os=OS.new(@ui);
		info("os initialized ...");
		# 3.init report system
		@report = MessageReport.new(@ui);
		info("message report initialized ...");
		# 4.init ipxact system
		@ipxact=Ipxact.new(@ui);
		info("ipxact system initialized ...");
		# 5.load required chains according to initialized ui.
		@ipxact.loadChain;
	end ##}}}

	## self.run, 
	# running the main tool
	def self.run; ##{{{
		begin
			# 1.call self.init that can automatically initialize.
			info("Rsim tool initializing ...",3);
			self.init;
			info("executing chains ...",3);
			self.execute;
		rescue RsimExceptionBase => e
			#TODO, may need more actions such for job controls etc.
			if @report
				self.report.error("captured exception #{e.type}, exited: #{e.exit?}");
				self.report.error("reason: #{e.reason}");
				self.report.error("\n-- Stack information: --\n#{e.stack}")
			else
				self.info("captured exception #{e.type}, exited: #{e.exit?}");
				self.info("reason: #{e.reason}");
				self.info("\n-- Stack information: --\n#{e.stack}")
			end
			return e.exitSignal if e.exit?;
		rescue Interrupt => e
			self.info ("get user interrupt signal: #{e.signo}")
			self.info("get user interrupt signal: #{e.signo}")
		end
		return 0;
	end ##}}}
	## self.execute, 
	# execute commands by given from config, executed by the plugin manager
	# flows={:node=>{option=>xxx,option=>xxx,...},:build=>{xxx},...}
	def self.execute; ##{{{
		flows=@ui.flowStream;
		flows.each_pair do |n,opts|
			@ipxact.send(n,opts);
		end
	end ##}}}

	## self.loadingNode(f=nil), description
	#TODO, set up current loading node context
	def self.loadingNode(f=nil); ##{{{
		return @node[:name] unless f;
		@node[:name]= f;
	end ##}}}
	## self.loadingPath(p=nil), set or get current loading file path
	def self.loadingPath(p=nil) ##{{{
		return @node[:path] unless p;
		@node[:path]= p;
	end ##}}}
end
