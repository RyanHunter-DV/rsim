# FlowBase
# object defined for being created by other built-in or user defined plugins.
# Created by global command: flow
############################################################
# Concepts:
# phase: the flow has a base feature which will be used to be executed by main tool
# besides, the step also has a phase concept that different threads will be executed according
# to the phase setting.
#

require 'FlowStep.rb'
class FlowBase
	
	## execute, method called by the main tool while executing this flow.
	#TODO
	def execute(ui) ##{{{
		#- while s=@steps.next
		#- s.shedule until s.reachMaxSlots(ui.maxjobs) or s.hasDependency.
		#- s.dispatch
	end ##}}}
end

## flow(name,&block), global method to create a new flow
def flow(name,&block) ##{{{
	# TODO
end ##}}}
