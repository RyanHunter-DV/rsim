"""
# Object description:
GeneratorExecutor, description
"""
class GeneratorExecutor ##{{{
	
	# the object of defined generator
	attr :definition;

	attr_accessor :name;
	attr_accessor :group;
	attr :__args__;

	## initialize, description
	def initialize(n,g); ##{{{
		@definition=g;
		@name = n.to_s;
		@__args__={};
	end ##}}}

	## context, return context of definition
	# context for :procedure typed action executing scope
	def context; ##{{{
		return @definition.context;
	end ##}}}
	## precedences, return definition's precedences
	def precedences; ##{{{
		return @definition.precedences;
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

	## arg(t), 
	# called by this class, return args sending from Ipx data, such as from Component
	def arg(t); ##{{{
		return @__args__[t];
	end ##}}}

	## execute, 
	# called by the chain, to execute the generator
	def execute(ctx=nil); ##{{{
		# if generator type is :system, eval the action block in this scope.
		cmd='';
		ctx=self if ctx=nil;
		blocks(:actions).each do |a|
			cmd= ctx.instance_eval a[1];
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