
"""
# Object description:
Dispatcher, 
# Object description:
## Internal job limitation management
## Threads control, create, wait, kill etc.
## Error collection from child process execution.
"""
require 'open3'
require 'lib/mts/Shell'
require 'lib/mts/Command'
class Dispatcher

	attr :logdir;
	attr :pids;

	# flag when main thread is in waiting procedures, no extra emit can be called.
	attr :isWaiting;
	attr_accessor :timeout;
	attr :timeoutFlag;

	## initialize, description
	def initialize(ui); ##{{{
		init(:logdir=>ui.logdir);
		@isWaiting=false;
	end ##}}}

	## init(**opts={}), description
	def init(**opts); ##{{{
		@logdir=opts[:logdir];
		@pids={};
		@timeout=10; # default 10 seconds
		@timeoutFlag=false;
	end ##}}}

	## buildInternalProc, build a lambda proc for executing internal typed commands
	def buildInternalProc(cmd); ##{{{
		p= -> {
			Rsim.info("scope: #{cmd.scope.inspect}",9);
			Rsim.info("block: #{cmd.exe}",9);
			if cmd.exe.class==Proc
				cmd.scope.instance_exec &cmd.exe;
			else
				cmd.scope.instance_eval cmd.exe;
			end
			exeBack="updateProcState(#{Process.pid},:status=>:finished,:exitstatus=>0);"
			writeExeBack(@logdir,Process.pid,exeBack);
		};
		return p;
	end ##}}}

	## buildCmdFile(f,c), write cmd into f
	def buildCmdFile(f,c); ##{{{
		fh = File.open(f,'w');
		fh.write(c);
		fh.close;
	end ##}}}

	## buildExternalProc(cmd), build a lambda proc for executing external typed command
	def buildExternalProc(cmd); ##{{{
		p= -> {
			scf=cmd.exe.gsub(/[ |\/|\||\\|\*|\.|\-]/,'_')+'-cmd';
			lname=cmd.exe.gsub(/[ |\/|\||\\|\*|\.|\-]/,'_')+'-exe.log';
			scf.gsub!(/[;]/,'--');lname.gsub!(/[;]/,'--');
			cmdf=File.join(cmd.scope,scf);
			log=File.join(@logdir,lname);
			buildCmdFile(cmdf,cmd.exe);
			o,e,s=Shell.exec(cmd.exe,cmd.scope);
			fh=File.open(log,'w');
			fh.write(o);
			fh.write(e) if s > 0;
			fh.close;
			# command to be executed back in main thread.
			exeBack="updateProcState(#{Process.pid},:status=>:finished,:exitstatus=>#{s});"
			writeExeBack(@logdir,Process.pid,exeBack);
		}
		return p;
	end ##}}}
	## writeExeBack(pid,cmd), used by sub thread to write execute back code into a file
	# which will be evaled by main thread
	def writeExeBack(path,pid,cmd); ##{{{
		ebf = File.join(path,"#{pid}-exe_back");
		fh=File.open(ebf,'w');
		fh.write(cmd);
		fh.close;
	end ##}}}
	## evalExeBack(path,pid), called by main thread to eval execute back code
	def evalExeBack(path,pid); ##{{{
		ebf=File.join(path,"#{pid}-exe_back");
		raise ShellException.new("file(#{ebf}) not exists") unless File.exists?(ebf);
		fh=File.open(ebf,'r');
		cmd=fh.readlines;
		self.instance_eval cmd;
	end ##}}}

	## updateSubProcState(pid,s), update sub proc state by giving pid and s => v pairs
	def updateProcState(pid,**pairs); ##{{{
		raise ShellException.new("pid(#{pid}) not exists!") unless @pids.has_key?(pid);
		Rsim.info("update target process(#{pid}) by process(#{Process.pid})",9);
		pairs.each_pair do |s,v|
			@pids[pid][s.to_sym]=v;
		end
	end ##}}}

	## createProcState(pid), create new hash object in @pids for given pid.
	def createProcState(pid,cmd); ##{{{
		@pids.delete(pid) if @pids.has_key?(pid);
		@pids[pid]={:status=>:running,:exitstatus=>0,:scope=>cmd.scope};
	end ##}}}

	# cmd is Command object instance.
	# return and record pid of subprocess.
	def emit(*cmds) ##{{{
		p=nil;
		raise ShellException.new("emit a new thread while in waitall") if @isWaiting==true;
		cmds.each do |cmd|
			p = self.send("build#{cmd.type.to_s.capitalize}Proc".to_sym,cmd);
			pid = fork &p;
			if pid!=0
				createProcState(pid,cmd);
				return pid;
			end
		end
		exit @pids[Process.pid].exitstatus;
	end ##}}}

	## waitPid(pid), wait for pid done, and process exe back
	def waitPid(pid); ##{{{
		Rsim.info("waiting for #{pid}",9);
		Process.wait(pid);
		Rsim.info("#{pid} waited",9);
		evalExeBack(@logdir,pid);
	end ##}}}

	## allPidsDone, if any of pid status is not :finished or :killed, return false
	def waitAllPidsDone; ##{{{
		@pids.each_pair do |pid,pinfo|
			waitPid(pid);
		end
		@pids={};
		return true;
	end ##}}}

	## waitall, to wait all emitted pids to be done, then return
	def waitall ##{{{
		@isWaiting=true;
		waitAllPidsDone;
		@isWaiting=false;
	end ##}}}

	#def wait(*pids) ##{{{
	#	pids.each do |pid|
	#		Rsim.info("waiting for #{pid}",9);
	#		Process.wait(pid);
	#		Rsim.info("#{pid} waited",9);
	#	end
	#	return 0; # TODO, need tell caller if pid failed.
	#end ##}}}
	
end
