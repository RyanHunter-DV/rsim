# FlowStep
# object defined to store infomation of a flow step, and can be dispatched
# as a parallel thread.
class FlowStep
	
	# pool has all scheduled Thread object here.
	@@schedulePool=[];

	## dispatch, all scheduled threads will be dispatched, 
	#TODO
	def dispatch ##{{{
		@@schedulePool.each do |s|
			s.join;
		end
	end ##}}}

	## schedule, create a new thread object for controll and push to schedulePool.
	#TODO
	def schedule ##{{{
		#- thd=Thread.new {o.instance_eval b...} with block defined by plugin creator
		#- @@schedulePool<<thd
	end ##}}}

	## reachMaxSlots(max), return true if current schedulePool has size >= max.
	#TODO
	def reachMaxSlots(max) ##{{{
		#- if schedulePool.length > max, report with tool error
		#- if schedulePool.length == max, return true
		#- return false
	end ##}}}

	## after(step,**opts), specify this step is after another one by giving the name.
	# opts[:blocked] = true/false -> if blocked is true, then current step shall wait for the given
	# step completed.
	#TODO
	def after(step,**opts) ##{{{
	end ##}}}

end
