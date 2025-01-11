"""
# Object description:
RsimFlow, 
The base object for user inheritance.
"""
require 'ipxact/IpxData.rb'
require 'mult/Job.rb'
class RsimFlow < IpxData

	attr :steps;
	# each flow has its own logger file in out/logs
	attr :logger;
	attr :jobs;
	attr :selected; # selected steps or generators
	## initialize(name), description

	attr :ename;

	attr :__args__; # args for generator chain scope
	attr :__updated__;
	def initialize(name); ##{{{
		super(:id=>name,:ipxact=>:chain)
		@steps={};@selected={};
		@jobs={};
		@__updated__=false;
	end ##}}}
	## name, return the generator chain id
	def name; ##{{{
		return @id;
	end ##}}}
	## exename, return the execute name if set, if not, then return flow name
	def exename ##{{{
		return @ename if @ename;
		return self.name;
	end ##}}}
	## exe(v), set execute name
	def exe(v) ##{{{
		@ename=v.to_s;
	end ##}}}

	## action, description
	def option; ##{{{
		return @__args__;
	end ##}}}
	
	## generator(name,&block), 
	# generator command in the chain
	# define a new generator, with given generator commands, to setup parameters, phases, actions etc.
	def generator(name,opts={},&block); ##{{{
		# by default, the context is the chain
		g=Generator.new(name,self);
		g.instance_eval &block;
		register(g,opts);
	end ##}}}

	## register(step), register the step into local @steps hash, if has no group
	# report error.
	# store all defined generators, its been defined but may not selected.
	def register(step,opts); ##{{{
		selected=false;
		if opts.has_key?(:selected)
			selected=opts[:selected];
			opts.delete(:selected);
		end
		@steps[step.name] = step;
		select(step.name,opts) if selected==true;
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
		# 1. select generators of this group
		@__args__ = opts;
		_pickupAndExecute while (@__updated__);
	end ##}}}
	## _pickupAndExecute(opts={}), 
	def _pickupAndExecute() ##{{{
		opts=@__args__;
		selected = _pickupExecutor(**opts);
		# 2.run generators
		selected.each do |e|
			Rsim.info("executing generator #{e.name}",8);
			#e.option(opts);
			if e.jobtype==:procedure
				#e.context.instance_eval e.action;
				e.execute(e.context);
			else
				# :system jobtype
				j=Job.new(e.jobtype,e.execute,:path=>e.root,:id=>e.name);
				e.precedences.each do |pre|
					@jobs[pre].wait if @jobs.has_key?(pre);
				end
				j.dispatch;
				@jobs[e.name] = j;
			end
		end
		
	end ##}}}
	## select(g), select generator name
	# select a generator to be executed with specific args
	# this method is similar of calling the execute command, 
	def select(gn,opts={}); ##{{{
		opts[:executed]=false unless opts.has_key?(:executed);
		@selected[gn]= opts;
		@__updated__ = true; # update flag of the selected generators
	end ##}}}
private
	## _pickupExecutor, 
	# create a new generator executor if the given generator is selected
	def _pickupExecutor(**eOpts); ##{{{
		ges=[];
		@selected.each_pair do |name,opts|
			next if opts[:executed];
			# 1.create new generator executor
			Rsim.exception(NodeE,:reason=>"generator #{name} not defined") unless @steps.has_key?(name);
			# 2.copy key information from generator
			e=GeneratorExecutor.new(name,@steps[name]);
			# 3.setup options in selected opts
			# 4.setup extra options from execute call.
			eOpts.each_pair do |k,v|
				opts[k]=v; # if eOpts has same key with opts, will overwrite the value in opts
			end
			e.option(opts);
			ges << e;
			opts[:executed]=true;
		end
		@__updated__=false; # clear updated flag once called _pickupExecutor
		return ges;
	end ##}}}
end


## flow(name,&block), 
# global method to define a new flow
# the new created flow will be registered to the Rsim.pm scope, by defining
# a method within the plugin manager.
def flow(name,&block); ##{{{
	isNew=false;
	f=Rsim.ipxact.find(name,:generatorChain,false);
	if f==nil
		f=RsimFlow.new(name);
		isNew=true;
	end
	f.instance_eval &block;
	Rsim.ipxact.register(f,:generatorChain) if isNew;
end ##}}}
