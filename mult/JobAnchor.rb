"""
# Object description:
JobAnchor, description
"""
class JobAnchor ##{{{

	attr __jobs__;

	## initialize, description
	def initialize; ##{{{
		@__jobs__={};
	end ##}}}


	## completed, description
	def completed(pid); ##{{{
		# return if given pid's anchor is completed
		if @__jobs__.has_key?(pid)
			fn=File.join(@__jobs__[pid].path,"COMPLETE.#{pid}")
			return true if File.exists(fn);
		end
		return false;
	end ##}}}
	## registerRunningProcess(pid,job), description
	def registerRunningProcess(pid,job); ##{{{
		@__jobs__[pid] = job;
	end ##}}}
end ##}}}