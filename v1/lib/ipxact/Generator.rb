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
class Generator ##{{{

	attr :exe;
	attr :action;

	## initialize(), description
	def initialize(); ##{{{
		puts "#{__FILE__}:(initialize()) is not ready yet."
		@exe='';
	end ##}}}

	## exe
	## Command to specify the executor path and name of generator's executor.
	## format: exe 'executor name'
	## exe(name) description
	def exe(e) ##{{{
		@exe = e;
	end ##}}}

	## run
	## API called by `component.generate` when the buildflow is called, according to the given arg from generate API
	## run(&block), 
	# generator single action for running
	def run(&block); ##{{{
		puts "#{__FILE__}:(run(&block)) is not ready yet."
		@action=block
	end ##}}}

	## cmd(s), execute the given command string with given args, the executor is in @exe
	def cmd(*args); ##{{{
		puts "#{__FILE__}:(cmd(s)) is not ready yet."
		s = Command.new(%Q|#{@exe} #{*args}|,:external);
		@dp.schedule(s);
	end ##}}}

	## generate
	## Called by component, call generate with specific arguments so that it can be called multiple times to run this generator.
	## **args**:
	## - o, object of Component, so can attach component contexts.
	## generate(o),
	def generate(o); ##{{{
		#puts "#{__FILE__}:(generate(o)) is not ready yet."
		self.instance_eval @action,o;
	end ##}}}

	
end ##}}}

## generator(name,&block), 
# provided by global, to create a new generator definition in MetaData scope.
# so that it can be used by components' generator command.
# built-in generators: 'copy', 'link'
def generator(name,&block); ##{{{
	puts "#{__FILE__}:(generator(name,&block)) is not ready yet."
	
end ##}}}