"""
# Object description:
RsimFlow, 
The base object for user inheritance.
"""
require 'libs/FlowStep.rb'
class RsimFlow ##{{{

	attr_accessor :name; # string type
	attr_accessor :currentOption;

	attr :steps;
	# each flow has its own logger file in out/logs
	attr :logger;
	## initialize(name), description
	def initialize(name); ##{{{
		@name = name.to_s;
		@steps=[];
		@currentOption=nil;
		# 1.init logger, open file with config.outs[:logs]+<flowname>.log
		#TODO
	end ##}}}

	## action, description
	def option; ##{{{
		return @currentOption;
	end ##}}}
	
	## step, 
	# command to define a new step of this flow, example:
	#step :name, do
	#	group :groupname
	#	action do
	#		Shell.cmd(...,...);
	#	end
	#end
	def step(name,**opts,&block); ##{{{
		#puts "#{__FILE__}:start step ..."
		s=FlowStep.new(name);
		s.action(block);
		register(s); # register step
	end ##}}}

	## register(step), register the step into local @steps hash, if has no group
	# report error.
	def register(step); ##{{{
		#puts "#{__FILE__}:start register(step) ..."
		# if no group, return nil
		#TODO, why need group?, Rsim.report.error("step(#{step.name} has no group declared !)") unless step.group; 
		#TODO, why need group?, @steps[step.group]=[] unless @steps.has_key?(step.group);
		#TODO, why need group?, @steps[step.group]<<step;
		@steps << step;
	end ##}}}
	## command(name,&block), define a new command(API) for
	# the newly created flow.
	def command(name,&block); ##{{{
		#puts "#{__FILE__}:start command(name,&block) ..."
		define_singleton_method name.to_sym do |*args,&desc| ##{{{
			info("setup command method #{name}, args (#{args})",9);
			self.instance_exec *args,desc,&block;
		end ##}}}
	end ##}}}
	## info(msg,verbo=9,depth=1), description
	def info(msg,verbo=9,depth=1); ##{{{
		depth+=1;
		Rsim.info(msg,verbo,depth);
	end ##}}}
	## execute(**opts), will execut the flow by given opts
	def execute(**opts); ##{{{
		#puts "#{__FILE__}:start execute(**opts) ..."
		select = nil;
		#select = opts[:select] if opts.has_key?(:select);
		select = _pickupSelectedSteps(opts[:select]) if opts.has_key?(:select);
		@steps.each do |s|
			next if select and (not select.include?(s.name.to_sym));
			info("executing step #{s.name}(#{opts}) ...",5);
			s.execute(self,**opts);
		end
	end ##}}}
private
	## _pickupSelectedSteps(s), description
	def _pickupSelectedSteps(s); ##{{{
		#puts "#{__FILE__}:start _pickupSelectedSteps(s) ..."
		return [s.to_sym] if s.is_a?(String);
		return [s] if s.is_a?(Symbol);
		return s;
	end ##}}}
end ##}}}


## flow(name,&block), 
# global method to define a new flow
# the new created flow will be registered to the Rsim.pm scope, by defining
# a method within the plugin manager.
def flow(name,&block); ##{{{
	#puts "#{__FILE__}:start flow(name,&block) ..."
	f=RsimFlow.new(name);
	f.instance_eval &block;
	Rsim.pm.register(f);
end ##}}}