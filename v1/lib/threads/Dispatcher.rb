
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
	def initialize; ##{{{
		puts "#{__FILE__}:(initialize) is not ready yet."
	end ##}}}

	## init(**opts={}), description
	def init(**opts={}); ##{{{
		puts "#{__FILE__}:(init(**opts={})) is not ready yet."
		@maxJobs=opts[:maxJobs] or 1;
	end ##}}}


	
end ##}}}
