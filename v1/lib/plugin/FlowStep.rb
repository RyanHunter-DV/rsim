"""
# Object description:
FlowStep, object to describe the flow steps.
"""
require 'lib/threads/Command.rb'
class FlowStep ##{{{
	
	#attr :successor;
	attr :container;

	attr_accessor :name;
	attr_accessor :predecessor;
	attr_accessor :with;
	attr_accessor :phase;
	attr_accessor :action;

	## initialize(n), 
	def initialize(n,o); ##{{{
		puts "#{__FILE__}:(initialize(n)) is not ready yet."
		@predecessor={:step=>nil,:blocked=>true};
		@with=[];
		@container=o;
		@name=n.to_s;
		@phase=0;
		@action=nil;
	end ##}}}

	## after(n), given the name of the step that this step
	# will called after it.
	def after(n,**opts={}); ##{{{
		#puts "#{__FILE__}:(after(n)) is not ready yet."
		@predecessor[:blocked]=opts[:blocked] if opts.has_key?(:blocked);
		n=n.to_s;
		s=@container.findStep(n);
		raise PluginException.new("cannot find step(#{n}) in flow(#{@container.name})") if n==nil;
		@predecessor[:step]=s;
		if (@predecessor[:blocked])
			@phase=s.phase+1;
		else
			@phase=s.phase;
		end
	end ##}}}

	## with(n), set a step that can be run with current step.
	def with(n); ##{{{
		n=n.to_s;
		s=@container.findStep(n);
		raise PluginException.new("cannot find step(#{n}) in flow(#{@container.name})") if n==nil;
		@with << s;
		if s.predecessor
			@predecessor=s.predecessor ;
			@phase=s.phase;
		end
		s.with(@name);
	end ##}}}
	## action(&block), 
	# the real actions to d by calling this step
	def action(t,&block); ##{{{
		return @action unless block;
		@action=Command.new(self) unless @action;
		@action.add(block,t);
	end ##}}}


end ##}}}