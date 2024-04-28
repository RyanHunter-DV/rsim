
"""
# Object description:
Dispatcher, 
# Object description:
## Internal job limitation management
## Threads control, create, wait, kill etc.
## Error collection from child process execution.
"""
class Dispatcher ##{{{

	attr :maxJobs;

	## initialize, description
	def initialize(ui); ##{{{
		puts "#{__FILE__}:(initialize) is not ready yet."
		init(ui.maxJobs);
	end ##}}}

	## init(**opts={}), description
	def init(**opts={}); ##{{{
		@maxJobs=opts[:maxJobs] or 1;
	end ##}}}


	
end ##}}}
