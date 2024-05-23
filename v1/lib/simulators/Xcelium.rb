require 'lib/Shell'
class Xcelium
	@@exes={:compile=>'xmvlog',:elab=>'xmelab',:sim=>'xmsim'};

	attr :userOptions;
	attr_accessor :name;
	## initialize, init
	def initialize ##{{{
		@name='Xcelium';
		@userOptions={:compile=>[],:elab=>[],:sim=>[]};
	end ##}}}
	## checkToolExistence, check if current env has specified
	# simulator installed.
	def checkToolExistence ##{{{
		@@exes.each_pair do |key,exe|
			results=Shell.exec("which #{exe}");
			raise EnvException.new("eda command(#{exe}) cannot found:#{results[0]}") if results[1]!=0;
		end
	end ##}}}
	## steps(t), return array of step names of given t, t can be [:build,:run]
	## build if for build simulation database, which can be compile -> elab
	## for Xcelium,
	# - steps(:build) -> [:compile,:elab]
	# - steps(:run) -> [:sim]
	def steps(t) ##{{{
		return [:compile,:elab] if t==:build;
		return [:sim] if t==:run;
		raise ToolException.new("invalid step type specified(#{t})");
	end ##}}}
	## addOptions(step,*args), add user options for specified step
	def addOptions(step,*args) ##{{{
		@userOptions[step].append(*args);
	end ##}}}

	## base(step), return basic tool executor and options for eda
	def base(step) ##{{{
		return %Q|#{@@exes[step]} -64BIT|;
	end ##}}}

	## command(step), return arranged command of this tool after loading nodes
	# step can be: :compile, :elab, :sim
	def command(step) ##{{{
		checkToolExistence;
		step=step.to_sym;
		cmd=base(step);
		@userOptions[step].each do |opt|
			cmd += ' '+opt;
		end
		return cmd;
	end ##}}}
end
