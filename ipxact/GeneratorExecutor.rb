"""
# Object description:
GeneratorExecutor, description
"""
class GeneratorExecutor
	
	# the object of defined generator
	attr :definition;

	attr_accessor :name;
	attr_accessor :group;
	attr_accessor :root;
	attr :__args__;
	attr :__cmds__;

	## initialize, description
	def initialize(n,g); ##{{{
		@definition=g;
		@name = n.to_s;
		@__args__={};
		@__cmds__=[];
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
	## exe, return definition's exec name
	def exe ##{{{
		# support override by the action block
		return option[:exec] if option.has_key?(:exec);
		return @definition.exec;
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
		ctx=self if ctx==nil;
		blocks(:actions).each do |a|
			Rsim.info("execute generator #{a[0]}, context: #{ctx}");
			cmd= ctx.instance_eval &a[1];
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
	## command(s), add the given command string s into command file: @__cmds__
	def command(s); ##{{{
		@__cmds__ << s+';';
	end ##}}}
	## blocks(t), arrange actions according to definition's actions
	def blocks(t,b=nil); ##{{{
		d=@definition;
		as=[];
		if t==:actions
			# build actions and return
			if d.jobtype==:system
				cmdf=%Q|#{d.name}.cmd|;
				p = lambda { |ctx|
					# block will call command to setup commands
					Rsim.info("executing the action definition(#{d.action[0]})",9);
					ctx.instance_eval &d.action[1];
					Rsim.info("build command file(#{cmdf}): #{@__cmds__}",9);
					Rsim.os.build(File.join(@root,cmdf),@__cmds__);
					%Q|sh #{cmdf}|;
				};
				as << [p.source_location,p];
				#p=lambda { |ctx|
				#	%Q|cd #{@root};source #{cmdf}|;
				#};
				#as << [p.source_location,p];
			else
				as << d.action;
			end
		end
		return as;
	end ##}}}
end
