"""
# Object description:
Plugin, An object that been created while the global flow API is called by user
plugin files, such as buildflow, compileflow ...
"""
# require 'lib/plugin/FlowBase.rb'
require 'lib/plugin/FlowStep.rb'
class Plugin
	attr :options; # options required to call different actions.
	# format: steps[:name] => object
	attr :steps;
	attr :api;
	attr_accessor :name;
	attr_accessor :dispatcher; # dispatcher
	# attr :basePhase;

	## initialize(n), description
	def initialize(n); ##{{{
		@name = n.to_sym;
		@api={};@steps={};
		@basePhase=0;
	end ##}}}
	## register(so), register the step into current plugin
	# so: step object
	def register(so); ##{{{
		puts "#{__FILE__}:(register(so)) is not ready yet."
		#1.check current so's dependency, if has after/before/with information
		after=so.predecessor[:step];
		#2.if has, then need find the index of the target step. and then insert
		# before/after or along with current step into @steps.
		so.phase=after.phase+0.1 if after and so.phase<=after.phase;
		#3.if has no dependency, then insert at the end of current @steps.
		@steps[so.name]=so;
	end ##}}}

	## findStep(n), 
	#
	def findStep(n); ##{{{
		n=n.to_s;
		return @steps[n] if @steps.has_key?(n);
		return nil;
	end ##}}}

	## arrangeStepOrdering, 
	# arrange the run ordering of steps, steps that has with relations or predecessor but blocked is false, then
	# those steps will be included in one sub array.
	# like: {0=>['pre_build'], 1=>['build','build2',...],2=>['post_build']}
	def arrangeStepOrdering; ##{{{
		sq={};
		@steps.each_value do |s|
			sq[s.phase]=[] unless sq.has_key?(s.phase);
			sq[s.phase] << s 
		end
		return sq;
	end ##}}}
	## run, built-in command called by internal tool like: <flowname>.run
	# this is the built-in entry to start running the certain flow plugin.
	def run; ##{{{
		# 1. arrange steps # for example: step is: pre_build -> build/build2 -> post_build
		# then arrange steps into: ['pre_build', ['build','build2'],'post_build']
		# 2. schedule, emit and wait for all step commands
		steps = arrangeStepOrdering;
		phases = steps.keys;phases.sort!;
		phases.each do |ph|
			pids=[];
			steps[ph].each do |step|
				# action is object of Command.
				step.actions.each do |action|
					pids<<@dispatcher.emit(action);
				end
			end
			raise ToolException.new("flow(#{@name} failed") if @dispatcher.wait(*pids);
		end
	end ##}}}
	# User commands for new plugin definition ##{{{
	## api(name,&block), To declare an api which will be called by internal through the API directly,
	# this api will be the method registered in PluginManageer, so it can be called like: Rsim.plugins.<api>
	#TODO
	def api(name,&block); ##{{{
		return @api if (name==nil);
		@api[:name] = name.to_sym;
		@api[:proc] = block;
	end ##}}}
	## step(name,&block), declare a flow step for this plugin
	#TODO
	def step(name,&block); ##{{{
		s=findStep(name);
		unless s
			#1.create new step of FlowStep object.
			s=FlowStep.new(name,self)
			#2.register into local @steps hash.
			register(s);
		end
		#3.evaluate the block within the created step object.
		s.instance_eval block;
	end ##}}}
	# }}}

end
