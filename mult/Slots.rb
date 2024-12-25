"""
# Object description:
Slots, description
"""
class Slots ##{{{

	attr :__max__;
	attr :__occupied__;

	attr :running;
	## initialize, description
	def initialize; ##{{{
		@__max__ = 10; # by default, max slots is 10
		@__occupied__ = 0;
		@running=[];
	end ##}}}
	## free, return current available slots.
	def free; ##{{{
		return @__max__ - @__occupied__;
	end ##}}}
	## apply(v), apply for slot
	def apply(v); ##{{{
		if @__occupied__+v > @__max__
			#TODO, Rsim.exception(JobE,:reason => "invalid apply number #{v}, current occupied #{@__occupied__}");
			remained =@__max__-@__occupied__;
			puts "Error, apply number #{v} exceed remained #{remained}";
			return 0;
		end
		@__occupied__ += v;
	end ##}}}
	## clear(v), description
	def clear(v); ##{{{
		@__occupied__ -= v;
	end ##}}}

	## clearCompletedJobs, description
	def clearCompletedJobs; ##{{{
		@running.each do |pid|
			# TODO, check the running log file, if has a COMPLETED.<pid> anchor, then is completed.
			if JobM.anchor.completed(pid)
				@__occupied__ -= 1;
				@running.delete(pid);
				break;
			end
		end
	end ##}}}
	## registerRunningProcess(pid), description
	def registerRunningProcess(pid); ##{{{
		@running << pid;
	end ##}}}
end ##}}}