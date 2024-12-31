"""
# Object description:
Job, job object been thrown into JobManager
"""
class Job ##{{{

	attr_accessor :id; # unique identifier of the job, is of int type
	attr_accessor :name; # meaningful name of the job, name is not unique item.

	# current status, :thrown, :waiting, :running, :killed, :finished
	# type is hash
	attr :__status__; 

	# job type,
	# :proc, gives a proc (or code block), can give with option of context, so will be evaled within the context or in main.
	# :system, gives a string command which will be run on os system.
	# :string, gives pure string, can specify context
	attr :__type__;
	attr :__exe__;

	# :context => xxx
	# :pid => process id for :system type.
	attr :__opts__;

	attr :__anchor__; # the anchor command

	## initialize, description
	def initialize(t,v,**opts); ##{{{
		@__type__ = t.to_sym; @__exe__=v;
		@__status__={:main=>:thrown,:signal=>nil,:message=>nil};
		@__opts__={};
		@__anchor__ = "rsim-job-anchor";
		@name = '<unknown>';
		if opts.has_key?(:name)
			@name = opts[:name];
			opts.delete(:name);
		end
		opts.each_pair do |k,v|
			@__opts__[k] = v;
		end
		JobM.register(self);
	end ##}}}

	## dispatch, dispatching the given job into JobM.
	def dispatch(path='.'); ##{{{
		JobM.applySlots(1,self); # apply for one empty slot, or else wait
		case (@__type__)
		when :system
			#opts={:path=>path};
			@__opts__[:path] = path;
			@__exe__ = @__anchor__+%Q| '#{@__exe__}' #{path}|;
		else
			puts "error,other job type not ready."
			# for :procedure type, given @__exe__ is a code block;
			# then to execute it
			#TODO
		end
		@__opts__[:pid] = JobM.execute(self,:sub=>true,:id=>@name+'-'+@id.to_s);
	end ##}}}
	## path, return the path option for system typed job
	def path; ##{{{
		return @__opts__[:path];
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
		unless @__opts__.has_key?(:pid)
			#TODO, for test, Rsim.report.error("pid for job #{@name} not ready, job not thrown");
			puts ("error, pid for job #{@name} not ready, job not thrown");
			return;
		end
		JobM.wait(@__opts__[:pid]);
	end ##}}}

	## status(n), return status with given name type,
	# - :signal, return the status signal,
	# - nil, return :thrown, :waiting, :running, :killed, :finished
	def status(n); ##{{{
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
end ##}}}