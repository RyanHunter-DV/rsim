class TestTemplate < IpXactData
	## initialize(name), description
	def initialize(name) ##{{{
		setupNameId(name,:name);
	end ##}}}
	
end

class Test < TestTemplate
	
end

## template(name,**opts), used by nodes, to specify a test template
def template(name,**opts,&block) ##{{{
	t=TestTemplate.new(name);
	t.addUserNode(block);
	MetaData.register(t);
	#TODO,
end ##}}}
## test(name,**opts), called by user nodes, to describe a test
def test(name,**opts,&block) ##{{{
	t=Test.new(name);
	t.addUserNode(block);
	MetaData.register(t);
	#TODO,
end ##}}}
