"""
# Object description:
GeneratorChain, description
"""
require 'lib/nls/IpXactData.rb'
require 'lib/nls/Generator.rb'
require 'lib/nls/Step.rb'
class GeneratorChain < IpXactData ##{{{

	attr :steps;
	attr :options;
	attr :prechains;
	attr :postchains;
	attr_accessor :format;

	## initialize(id), description
	def initialize(id); ##{{{
		super(id);
		@steps=[];
		@options={};
		@format=[];
		@prechains={};@postchains={};
	end ##}}}

	## generator(id,&block), 
	# declare a new generator for this GC.
	def generator(id,&block); ##{{{
		#1. build new Generator object.
		g=Generator.new(id,&block);
		#2. define_singleton_method with generator id
		# method will be called like: <method>(**opts)
		self.define_singleton_method id.to_sym do |opts|
			g.run(opts);
		end
	end ##}}}

	## injectSteps(s,after,before), 
	#
	def injectSteps(s,after,before); ##{{{
		if after==nil and before==nil
			@steps << s;
			return;
		end
		# if after available, then will look at after only
		if after
			i=stepRegistered(after);
			raise FatalE.new("target step #{after} not registered") if i==false;
			Rsim.info("registering #{s.id} after #{after}",9);
			@steps.insert(i+1,s);
			return;
		end
		if before
			i=stepRegistered(before);
			raise FatalE.new("target step #{before} not registered") if i==false;
			Rsim.info("registering #{s.id} before #{before}",9);
			@steps.insert(i,s);
			return;
		end
	end ##}}}

	## stepRegistered(name), description
	def stepRegistered(name); ##{{{
		name=name.to_s;
		@steps.each_with_index do |s,index|
			return index if s.id==name;
		end
		return false;
	end ##}}}
	## deleteStep(name), description
	def deleteStep(name); ##{{{
		@steps.each_with_index do |s,index|
			if s.id==name
				@steps.delete_at(index);
				return;
			end
		end
		return;
	end ##}}}

	## step(name,&block), declare a step for running GC, if the step is already declared
	# then will override the old one.
	# steps will be called in execute function as format like:
	# step.run(options)
	def step(name,opts={},&block); ##{{{
		name=name.to_s;
		#puts "#{__FILE__}:(step(name,&block)) is not ready yet."
		if stepRegistered(name) != false
			Rsim.info("step(#{name}) of #{@id} been overridden")
			deleteStep(name); 
		end
		a=nil;b=nil;
		a=opts[:after]  if opts.has_key?(:after);
		b=opts[:before] if opts.has_key?(:before);
		s=Step.new(name,&block); #TODO
		injectSteps(s,a,b);
	end ##}}}

	## formatOptions(cmd), 
	# format the cmd like: build(:Config) to
	# :config=>'Config' ...
	def formatOptions(arg); ##{{{
		Rsim.info("Formatting arg(#{arg})",9)
		args=arg.split(' *, *');
		Rsim.info("args(#{args})",9);
		opts={};
		raise FatalE.new("the GeneratorChain(#{@id}) has no option formatted!") if @format.empty?;
		args.each_with_index do |a,i|
			break if i>=@format.length;
			Rsim.info("formatting arg(#{a}) of position(#{i})",9)
			opts[@format[i].to_sym]= a;
		end
		return opts;
	end ##}}}

	## runChain(api,args), run generator chain through MetaData,
	# like calling -e by user
	def runChain(api,args); ##{{{
		#puts "#{__FILE__}:(runChain(api,args)) is not ready yet."
		a=self.instance_eval args;
		cmd={
			:api => api,
			:args=> a,
			:skipped=>[]
		}
		MetaData.instance_eval %Q|#{cmd[:api]}(#{cmd})|;
	end ##}}}

	## prechain(api,args), 
	# store into @prechains
	def prechain(api,args); ##{{{
		Rsim.info("set prechain(#{api}),args(#{args})",9);
		@prechains[api.to_s]=args;
	end ##}}}
	## postchain(api,args), similar as prechain
	def postchain(api,args); ##{{{
		@postchains[api.to_s]=args;
	end ##}}}

	## execute, the common API called by command options like: build(:Config)
	# options are all coming from the UI object.
	def execute(opts={}); ##{{{
		Rsim.info("execute generator chain (#{@id})",9)
		@options = formatOptions(opts[:args]);
		# skip can only skip dependent chains, not the steps.
		skips=[];
		skips=opts[:skipped] if opts.has_key?(:skipped);
		@prechains.each_pair do |p,args|
			p=p.to_s;
			next if skips.include?(p);
			runChain(p,args);
		end
		@steps.each do |s|
			s.run(@options);
		end
		@postchains.each_pair do |p,args|
			p=p.to_s;
			next if skips.include?(p);
			runChain(p,args);
		end
	end ##}}}
end ##}}}

## generatorChain,
# command called by nodes, to declare a new GeneratorChain and register to MetaData.
#
def generatorChain(id,&block); ##{{{
	# the GC can be defined multiple times by calling this API, so that even the
	# built-in GC can also customized by users if they want add a custom step in build GC.
	isNew=false;
	gc=MetaData.find(id,:GeneratorChain);
	if gc==nil
		gc=GeneratorChain.new(id);
		isNew=true;
	end

	gc.instance_eval(&block);
	MetaData.register(gc,:GeneratorChain) if isNew;
	MetaData.define_singleton_method id.to_sym do |opts={}|
		Rsim.info("calling api(#{id}),args(#{opts})",9)
		gc.execute(opts);
	end
end ##}}}

# example to declare a generator chain
"""
generatorChain :build do
	# declare generators for this GC
	generator :name do
		# specify the phase of this generator to run,
		# given a float to specify phases, the flow in same integer value
		# indicates has no dependencies, while in different integer has.
		# for example, phase 1.0 and 1.1 has no dependencies, 
		# phase 1.2 and 2.0 has dependencies, the jobs shall be issued after previous are done.
		phase 0 
	end
	# step, declare steps while the GC has been called through the API: execute(**opts)
	# use before or after option to set the position of this step.
	step :build_rtl,before: <stepname>,after: <stepname> do
		@options
	end
end

"""