class Vcs
	attr :options;
	attr :workarea;
	attr_accessor :exename;
	## initialize, description
	def initialize(home) ##{{{
		@workarea=home;
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
		s=_builtinOptions(t);
		s.append(*@options[t.to_sym]);
		return s.join(' ');
	end ##}}}
	## incdirOption, description
	def incdirOption ##{{{
		return '+incdir+';
	end ##}}}
private
	## _builtinOptions(t), description
	def _builtinOptions(t) ##{{{
		s=[];
		if t==:comp
			s<<%Q|-f #{@workarea}/filelist.f|;
		end
		return s;
	end ##}}}
end
class Simulator
	attr :name; # eda name, and also indicates the eda type
	attr :tool; # tool object
	attr :home;
	## initialize(opts), initialize a simulator
	def initialize(opts) ##{{{
		n = opts[:name];
		@home=opts[:home];
		self.send("build#{n}".to_sym,opts[:exe]);
	end ##}}}
	## buildVcs, building for vcs simulator
	def buildVcs(b) ##{{{
		@name = 'vcs';
		@tool=Vcs.new(@home);
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
	## incdir, return incdir option
	def incdir ##{{{
		return @tool.incdirOption;
	end ##}}}
end
