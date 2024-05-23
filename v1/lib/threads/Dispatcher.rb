
"""
# Object description:
Dispatcher, 
# Object description:
## Internal job limitation management
## Threads control, create, wait, kill etc.
## Error collection from child process execution.
"""
require 'open3'
class Dispatcher

	attr :maxJobs;
	attr :logdir;
	attr :pids;
	attr :isWaiting;

	## initialize, description
	def initialize(ui); ##{{{
		init(:maxJobs=>ui.maxJobs,:logdir=>ui.logdir);
		@isWaiting=false;
	end ##}}}

	## init(**opts={}), description
	def init(**opts); ##{{{
		@maxJobs=opts[:maxJobs] or 1;
		@logdir=opts[:logdir];
		@pids=[];
	end ##}}}

	# cmd is Command object instance.
	# return and record pid of subprocess.
	def emit(cmd) ##{{{
		p=nil;
		raise UserException.new("emit a new thread while in waitall") if @isWaiting==true;
		if cmd.isBuiltinCommand
			p= -> {
				Rsim.info("scope: #{cmd.scope.inspect}",9);
				Rsim.info("block: #{cmd.exe}",9);
				cmd.scope.instance_exec &cmd.exe;
			};
		else
			p= -> {
				o,e,s = Open3.capture3(cmd.exe);
				ln=cmd.exe.gsub(/[ |\/|\||\\|\*|\.|\-]/,'_')+'-exe.log';
				log=File.join(@logdir,ln);
				fh=File.open(log,'w');
				if s.success?
					fh.write(o);
					fh.close;
				else
					fh.write(e);
					fh.close;
					Shell.exec("cat #{log}");
					raise ToolException.new("cmd(#{cmd.exe}) failed");
				end
			};
		end
		pid = fork &p;
		if pid!=0
			@pids << pid;
			return pid;
		end
		exit 0;
	end ##}}}

	## waitall, to wait all emitted pids to be done, then return
	def waitall ##{{{
		@isWaiting=true;
		@pids.each do |pid|
			Rsim.info("waiting for #{pid}",9);
			Process.wait(pid);
			Rsim.info("#{pid} waited",9);
		end
		@pids=[]; # clear pending pids
		@isWaiting=false;
	end ##}}}

	def wait(*pids) ##{{{
		pids.each do |pid|
			Rsim.info("waiting for #{pid}",9);
			Process.wait(pid);
			Rsim.info("#{pid} waited",9);
		end
		return 0; # TODO, need tell caller if pid failed.
	end ##}}}
	
end
