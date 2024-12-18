"""
# Object description:
RsimExe, the executor of rsim tool, all actions shall be dispatched through the executor
1.support running third party system command, such as linux cmd.
2.support calling internal methods of rsim tool.
	1.internal method calling is always in main thread.
"""
class RsimExe ##{{{
	
	## run(o,steps), calling steps in parallel, if require running in serial, need call run with one
	# step.
	# steps is array of Step objects.
	def run(steps); ##{{{
		puts "#{__FILE__}:start run(steps) ..."
		#TODO, need add management methods, such like ways that can:
		# kill threads by manually.
		# get return information, such as success or failed.
		threads=[];
		steps.each do |s|
			threads << Thread.new {step};
		end
		threads.each do |th|
			th.join;
		end
	end ##}}}
end ##}}}