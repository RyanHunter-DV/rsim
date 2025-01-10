"""
# Object description:
Job, job object been thrown into JobManager
"""
require 'mult/JobM.rb'
class Job

	attr_accessor :id; # meaningful name of the job, name is unique item.
	attr_accessor :pid; # the process id while executing

	# type is hash
	# [:main] -> :open, :waiting, :running, :killed, :finished
	# [:signal] -> for :system type only, the return signal.
	# [:message] -> future development.
	attr :__status__; 

	# job type,
	# :proc, gives a proc (or code block), can give with option of context, so will be evaled within the context or in main.
	# :system, gives a string command which will be run on os system.
	attr :__type__;
	# for :proc, it's code block,
	# for :system, it's command string.
	attr :__exe__;

	# :context => xxx
	# :pid => process id for :system type.
	attr :__opts__;

	# for :system type only
	attr :__anchor__; # the anchor command
	attr :__path__; # execute path

	# for :proc type only
	attr :__thd__; # thread handler

	## initialize, description
	def initialize(t,v,**opts); ##{{{
		@__type__ = t.to_sym; @__exe__=v;
		@__status__={:main=>:open,:signal=>nil,:message=>nil};
		@__opts__={};
		@__anchor__ = "rsim-job-anchor";
		@__path__='.';@pid=0;

		@id= opts[:id];opts.delete(:id);

		if opts.has_key?(:path)
			@__path__=opts[:path];
			opts.delete(:path);
		end
		opts.each_pair do |k,v|
			@__opts__[k] = v;
		end
		#JobM.register(@id,self);
	end ##}}}

	## dispatch, dispatching the given job
	def dispatch; ##{{{
		JobM.applySlots(1,self); # apply for one empty slot, or else wait
		case (@__type__)
		when :system
			#1. build cmd commands through Rsim.os
			#fn=_buildCmdFile;
			#2. build source command by using anchor
			cmd =@__anchor__+%Q| '#{@__exe__}' #{@__path__}|;
			Rsim.info("throwing job (#{cmd})",8);
			#3. call with Process.spawn, and record pid
			@pid=Process.spawn(cmd);
			#TODO, 4. require a job anchor process to monitor the job anchor flag changes.
			#TODO, create a new Thread?
		when :proc
			#2. create proc with two more steps:
			p=lambda {
				#2.1. update status to run
				@__status__[:main]=:running;
				#2.2. eval the proc with given context
				context= @__opts__[:context] or self;
				context.instance_eval &@__exe__;
				#2.3. update status to finished
				@__status__[:main]=:finished;
			};
			#3. call with Thread.new
			@__thd__ = Thread.new &p;
		end
	end ##}}}
	## path, return the path option for system typed job
	def path; ##{{{
		return @__path__;
	end ##}}}

	## type, description
	def type; ##{{{
		return @__type__;
	end ##}}}
	## command, description
	def command; ##{{{
		return @__exe__;
	end ##}}}
	## wait, wait this job completed.
	def wait; ##{{{
		unless @pid
			Rsim.report.error("pid for job #{@id} not ready, job not thrown");
			return;
		end
		JobM.wait(@pid);
	end ##}}}

	## status(n), return status with given name type,
	# - :signal, return the status signal,
	# - nil, return :thrown, :waiting, :running, :killed, :finished
	def status(n=nil); ##{{{
		return @__status__[:main] if n==nil;
		return @__status__[n.to_sym];
	end ##}}}

	## updateState(v)
	def updateState(v); ##{{{
		# update the :main in the status
		@__status__[:main]=v.to_sym;
	end ##}}}

private
	# building private methods

	## _buildCmdFile, build command file according to the @__exe__
	# string, then return the file name
# cmd file naming rule: <id>.cmd
	#def _buildCmdFile ##{{{
	#	fn="#{@id}.cmd";
	#	Rsim.os.create(:file,fn,@__path__);
	#	fh=File.open(File.join(@__path__,fn),'w');
	#	@__exe__.split(';').each do |line|
	#		fh.write("#{line}\n");
	#	end
	#	fh.close;
	#	return fn;
	#end ##}}}
end
