class TestTemplate < IpXactData
	attr_accessor :simopts;
	attr_accessor :whens;
	attr_accessor :config;
	## initialize(name), init
	def initialize(name,t=:template) ##{{{
		#TODO
		@simopts=[];@whens=[];
		super(t);
		setupNameId(name,:name);
	end ##}}}
	
	## config(cn), set config name
	def config(cn) ##{{{
		@config=cn.to_sym;
	end ##}}}

	## simopt(*args), specify sim options like:
	# simopt '+UVM_TESTNAME=xxx','+xxx=xxx'
	def simopt(*args) ##{{{
		@simopts.append(*args);
	end ##}}}
	## _when(*tags), support when tags for regression
	def _when(*tags) ##{{{
		@whens.append(*tags);
	end ##}}}
end
## template, called by user nodes, to declare a test template
def template(name,**opts,&block) ##{{{
	t=TestTemplate.new(name);
	t.addUserNode(block);
	#opts currently not used for template.
	MetaData.register(t);
end ##}}}
