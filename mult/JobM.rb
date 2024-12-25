# this is the job management module, control the namespace and main job actions
require 'mult/JobAnchor.rb'
require 'mult/Job.rb' # the job object, each job that been thrown shall be Job class object.
require 'mult/Slots.rb'
module JobM

	@@__slots__=nil;
	@@__id__ = 0;
	@@__anchor__=nil;

	## self.anchor, description
	def self.anchor; ##{{{
		@@__anchor__ = JobAnchor.new unless @@__anchor__;
		return @@__anchor__;
	end ##}}}
	## self.applySlots(v=1), apply for required slots
	# if current free slots not meet the requirement, then
	# need wait for jobs done.
	def self.applySlots(v=1,job); ##{{{
	#TODO
		job.updateState(:waiting) if slots.free < v;
		while slots.free < v
			self.waitSlotsUpdate;
		end
		slots.apply(v);
	end ##}}}
	## self.clearSlots(v=1), description
	def self.clearSlots(v=1); ##{{{
		slots.clear(v);
	end ##}}}
	## self.wait(pid), description
	def self.wait(pid); ##{{{
		Process.wait pid;
		self.clearSlots;
	end ##}}}

	## self.execute(p,job,**opts), executing the given proc
	def self.execute(job,**opts); ##{{{
		job.updateState(:running);
		if job.type== :system
			#pid=Process.spawn(job.command);
			#TODO, cannot test in windows
			pid=Process.spawn(job.command);
			#self.anchor.clear(pid); anchor can only build by sub process.
			self.slots.registerRunningProcess(pid);
			self.anchor.registerRunningProcess(pid,job);
		else
			puts "Error, mult-threads not ready."
			# #TODO, use multiple thread to thrown the job
			# thr=Thread.new {job.instance_eval p};
			# job.thread= thr;
			# thr.join;
			# # TODO, test for thr
		end
	end ##}}}

	## self.register(o), description
	def self.register(o); ##{{{
		o.id= @@__id__;
		@@__id__ += 1;
	end ##}}}

	## slots, description
	def self.slots; ##{{{
		@@__slots__ = Slots.new unless @@__slots__;
		return @@__slots__;
	end ##}}}
private
	## waitSlotsUpdate, description
	def self.waitSlotsUpdate; ##{{{
		current = self.slots.free;
		while true
			#system('sleep 1');
			self.slots.clearCompletedJobs;
			break if self.slots.free > current;
		end
	end ##}}}

end