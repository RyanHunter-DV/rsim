"""
# Object description:
RsimFlow, 
The base object for user inheritance.
"""
require 'libs/Generator.rb'
require 'ipxact/IpxData.rb'
class RsimFlow < IpxData ##{{{

	#attr_accessor :name; # string type
	attr_accessor :currentOption;

	attr :steps;
	# each flow has its own logger file in out/logs
	attr :logger;
	attr :jobs;
	## initialize(name), description
	def initialize(name); ##{{{
		#@name = name.to_s;
		super(name)
		@steps=[];
		@currentOption=nil;
		@jobs={};
		# 1.init logger, open file with config.outs[:logs]+<flowname>.log
		#TODO
	end ##}}}
	## name, return the generator chain id
	def name; ##{{{
		return @id;
	end ##}}}

	## action, description
	def option; ##{{{
		return @currentOption;
	end ##}}}
	
	## generator(name,&block), 
	# generator command in the chain
	# define a new generator, with given generator commands, to setup parameters, phases, actions etc.
	def generator(name,&block); ##{{{
		g=Generator.new(name);
		g.instance_eval &block;
		register(g);
	end ##}}}

	## register(step), register the step into local @steps hash, if has no group
	# report error.
	def register(step); ##{{{
		@steps[step.name] = step;
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
		selected = [];
		# 1. select generators of this group
		selected = @steps;
		# 2.run generators
		selected.each do |ge|
			if ge.jobtype==:procedure
				ge.context.instance_eval ge.action;
			else
				# :system jobtype
				j=Job.new(ge.jobtype,ge.execute);
				ge.precedences.each do |pre|
					@jobs[pre].wait if @jobs.has_key?(pre);
				end
				j.dispatch;
				@jobs[ge.name] = j;
			end
		end
	end ##}}}
	## select(g), select generator name
	def select(*as); ##{{{
		as.each do |a|
			@steps<<a;
		end
	end ##}}}
private
end ##}}}


## flow(name,&block), 
# global method to define a new flow
# the new created flow will be registered to the Rsim.pm scope, by defining
# a method within the plugin manager.
def flow(name,&block); ##{{{
	f=DataBase.find(name,:generatorChain,false);
	if f==nil
		f=RsimFlow.new(name);
		DataBase.register(f,:generatorChain);
	end
	f.instance_eval &block;
end ##}}}