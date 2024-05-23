## Examples:
## generator 'copy' do
## 	exe '/bin/cp'
## 	run do |o|
## 		o.fileSets.each do |src|
## 			target=o.outs[:vlnv]
## 			cmd src,arg1,target
## 		end
## 	end
## end

"""
# Object description:
Generator,
"""
class Generator < IpXactData

	attr :exe;
	attr :action;

	## initialize(), description
	def initialize(n); ##{{{
		#puts "#{__FILE__}:(initialize()) is not ready yet."
		super(:generatorChain);
		setupNameId(n,:nameGroup);
		@exe='';
	end ##}}}

	## exe
	## Command to specify the executor path and name of generator's executor.
	## format: exe 'executor name'
	## exe(name) description
	def exe(e) ##{{{
		@exe = e;
	end ##}}}

	## cmd(s), execute the given command string with given args, the executor is in @exe
	def cmd(*args); ##{{{
		as='';
		Rsim.info("args: (#{args})",9);
		args.each do |a|
			as+=" #{a}";
		end
		cmdS =%Q|#{@exe} #{as}|;
		Rsim.info("generate cmd: (#{cmdS})",9);
		s = Command.new(self);
		s.add(cmdS,:extern);
		Rsim.dp.emit(s);
	end ##}}}

	## clear(dir), clear the existing component path
	def clear(dir) ##{{{
		Shell.exec("rm -rf #{dir}");
	end ##}}}

	## generate
	## Called by component, call generate with specific arguments so that it can be called multiple times to run this generator.
	## **args**:
	## - o, object of Component, so can attach component contexts.
	## generate(o),
	def generate(o,**opts); ##{{{
		#puts "#{__FILE__}:(generate(o)) is not ready yet."
		raise ToolException.new("no out path specified to build a component") unless opts.has_key?(:out);
		clear(opts[:out]) if File.exists?(opts[:out]);
		Shell.makedir(opts[:out]);
		self.instance_exec {@action.call(o,**opts)};
	end ##}}}

	## action(&b), register the block into current @action
	def action(&b) ##{{{
		@action=b;
	end ##}}}
	
end

## generator(name,&block), 
# provided by global, to create a new generator definition in MetaData scope.
# so that it can be used by components' generator command.
# built-in generators: 'copy', 'link'
def generator(name,&block); ##{{{
	puts "#{__FILE__}:(generator(name,&block)) is not ready yet."
	g=Generator.new(name);
	g.instance_eval &block;
	MetaData.register(g);
end ##}}}
