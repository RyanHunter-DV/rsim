class Vcs
	attr :options;
	attr_accessor :exename;
	## initialize, description
	def initialize ##{{{
		@options = {:comp=>[],:elab=>[],:run=>[]};
		@exename = {:comp=>'vlogan',:elab=>'vcs'};
	end ##}}}

	## comp(*args), compile options
	def comp(*args) ##{{{
		@options[:comp].append(*args);
	end ##}}}
	## elab(*args), elab options
	def elab(*args) ##{{{
		@options[:elab].append(*args);
	end ##}}}
	## optionString(t), description
	def optionString(t) ##{{{
		s=@options[t.to_sym];
		return s.join(' ');
	end ##}}}
end
class Simulator
	attr :name; # eda name, and also indicates the eda type
	attr :tool; # tool object
	## initialize(opts), initialize a simulator
	def initialize(opts) ##{{{
		n = opts[:name];
		self.send("build#{n}".to_sym,opts[:exe]);
	end ##}}}
	## buildVcs, building for vcs simulator
	def buildVcs(b) ##{{{
		@name = 'vcs';
		@tool=Vcs.new();
		@tool.instance_eval &b;
	end ##}}}
	## buildXcelium, build xcelium simulator
	def buildXcelium ##{{{
		@name='xcelium';
		#TODO, need support for xcelium
	end ##}}}
	## exe(t), return execute name by given type
	def exe(t) ##{{{
		return @tool.exename[t.to_sym];
	end ##}}}
	## options(t), return option string by given type
	def options(t) ##{{{
		@tool.optionString(t);
	end ##}}}
end
