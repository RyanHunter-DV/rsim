"""
# Object description:
Generator, Object for a generator chain or component generator.
Provides commands for generator definition users to build a generator plugin.
"""
class Generator ##{{{

	attr :transportMethod;
	attr :name;

	attr :execHome;
	attr :subsequents;

	## initialize(), 
	#
	# api called like:
	# - Generator.new(name,'out/build/cmds/...')
	def initialize(n,h); ##{{{
		puts "#{__FILE__}:(initialize()) is not ready yet."
		# 1. build initial values and fields
		@transportMethod= :SOAP;
		@name=n;
		@execHome=h; # The default execHome set while new object instance created.
		@subsequents={};
		# 2. eval the user defined code block.
		# 3. setup a new method with this generator name in DesignConfig class later after all configs elaborated.
	end ##}}}

	## parameters(opts={}), specify parameters with: :type=>'value'
	# t-> type, one of :set, :support
	# opts={}, 
	# for support, :optionName=>:mandatory or :optional, :priority=>value
	# for set, :optionName=>'optionValue'
	def parameter(t,**opts={}); ##{{{
		# t-> type, used as key in @options
		# v-> value, option values
		# p-> priority
		#TODO, delete, puts "#{__FILE__}:(parameters(opts={})) is not ready yet."
		t=t.to_sym;v=v.to_s;
	end ##}}}

	## setup, call to assemble generator chain and build cmd files.
	def setup; ##{{{
		puts "#{__FILE__}:(setup) is not ready yet."
		# 1. if has exe, then build *.cmd file
		# 1.1.search @parameters, arrange it with priority, all parameter configs from config are now added in this generator
		# need confirm the config.elaborate shall be called before starting setup->run the generator chain.
		# 1.2.build file within the @execHome, cmd file name is: <component>-<generator>_exec.cmd
		# 1.3.store the command of this generator: 'source <component>-<generator>_exec.cmd'
		# 2. call subsequents' setup API
	end ##}}}

	## execute, call this API will directly start to run the pre-built cmd file.
	def execute; ##{{{
		puts "#{__FILE__}:(execute) is not ready yet."
		# 1. if has .cmd file, call with parallel thread
		# 2. search all subsequents, if has no dependency, call their execute directly
		# 3. wait for current .cmd file done, then search remained depedent subsequents, call their execute.
	end ##}}}

	## commands for customizing a generator {{{
	## selector(g,n,t), specify a subsequent generator and it's type
	# which will be stored into local object DB, and are ready to be run
	# while calling the parent generator's run API
	# n->generator name, if is string, need build a new instance, else directly use it
	# opts->
	# [:target], option for component generator, set the target component
	# [:phase], set the phase of next generator
	# [:depends], dependency of selected generator, if it's tree, then it depends on the generators been finished whose phase is smaller then this one..
	def selector(n,**opts={}); ##{{{
		puts "#{__FILE__}:(selector(g,n,t)) is not ready yet."
		# 1.store into @subsequents hash,
		# format, subsequents[:group]= g, subsequents[:obj]=Rsim.findGeneratorChain(xxx) or Rsim.findComponentChain
		# 2.
	end ##}}}

	## exe(n), specify the executor of this generator, only if
	# the exe exists, will be able to build the *.cmd file.
	def exe(n); ##{{{
		puts "#{__FILE__}:(exe(n)) is not ready yet."
		#TODO
	end ##}}}
	## transportMethod(m), specify the transportMethod, by default it's :SOAP.
	def transportMethod(m); ##{{{
		puts "#{__FILE__}:(transportMethod(m)) is not ready yet."
		@transportMethod=m;
	end ##}}}

	## }}}


end ##}}}


## generator(name,&block), 
# used by generator definition to build a new typed top generator chain
def generator(name,&block); ##{{{
	# TODO	
	# 1.create a new Generator object with the given name.
	# 2.
end ##}}}