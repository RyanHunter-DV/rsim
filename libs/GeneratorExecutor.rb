"""
# Object description:
GeneratorExecutor, description
"""
class GeneratorExecutor ##{{{
	
	attr :definition;

	attr_accessor :name;
	attr_accessor :group;
	# context for :procedure typed action executing scope
	attr_accessor :context;

	attr :__args__;
	## initialize, description
	def initialize(n,gn); ##{{{
		@definition=nil;
		@name = n.to_s;
		@group= gn.to_s;
		@__args__={};
	end ##}}}

	## option(opts=nil), if opts not nil, then
	# set options into local __args__
	# else return local __args__
	def option(opts=nil); ##{{{
		return @__args__ unless opts;
		if opts
			opts.each do |k,v|
				@__args__[k]=v;
			end
		end
	end ##}}}

	## updateDefinition(o), 
	# 1.update the @definition with given generator object
	# 2.set parameters
	def updateDefinition(o); ##{{{
		@definition=o;
	end ##}}}
	## sendArgs(**args), receive args from component or other generator usage
	def sendArgs(**args); ##{{{
		args.each_pair do |k,v|
			@__args__[k]=v;
		end
	end ##}}}

	## args(t), 
	# called by this class, return args sending from Ipx data, such as from Component
	def args(t); ##{{{
		return @__args__[t];
	end ##}}}

	## execute, 
	# called by the chain, to execute the generator
	def execute; ##{{{
		# if generator type is :system, eval the action block in this scope.
		cmd='';
		blocks(:actions).each do |a|
			cmd= self.instance_eval a[1];
		end
		return cmd if @definition.jobtype==:system;
	end ##}}}

	## action, return action blocks
	def action; ##{{{
		return blocks(:actions);
	end ##}}}
	## jobtype, return jobtype from definition
	def jobtype; ##{{{
		return @definition.jobtype;
	end ##}}}
	## precedences, return definition's precedences
	def precedences; ##{{{
		return @definition.precedences;
	end ##}}}
	## blocks(t), 
	def blocks(t,b=nil); ##{{{
		return o.actions if t==:actions;
	end ##}}}
end ##}}}