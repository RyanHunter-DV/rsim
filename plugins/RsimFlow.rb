"""
# Object description:
RsimFlow, 
The base object for user inheritance.
"""
require 'plugins/FlowStep.rb'
class RsimFlow ##{{{
	
	## step, 
	# command to define a new step of this flow, example:
	#step :name, do
	#	group :groupname
	#	action do
	#		Shell.cmd(...,...);
	#	end
	#end
	def step(name,&block); ##{{{
		puts "#{__FILE__}:start step ..."
		s=FlowStep.new(name);
		s.instance_eval block;
		register(s);
	end ##}}}

	## register(step), register the step into local @steps hash, if has no group
	# report error.
	def register(step); ##{{{
		puts "#{__FILE__}:start register(step) ..."
		# if no group, return nil
		App.report.error("step(#{step.name} has no group declared !)") unless step.group; 
		@steps[step.group]=[] unless @steps.has_key?(step.group);
		@steps[step.group]<<step;
	end ##}}}
end ##}}}