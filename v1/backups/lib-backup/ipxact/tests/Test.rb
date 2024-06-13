class Test < TestTemplate
	attr_accessor :parent;
	## initialize(name), description
	def initialize(name) ##{{{
		@parent=nil;
		super(name,:test);
	end ##}}}

	## clones(p), copy blocks from given template name.
	def clones(p) ##{{{
		o=MetaData.find(p,:template);
		raise UserNodeException.new("template(#{p}) not found") unless o;
		addUserNode(o.nodes);
		@parent=p;
	end ##}}}

	## finalize, only test has finalize, shall be called, template is a pure template which
	# has no finalize behavior
	def finalize ##{{{
		raise UserNodeException.new("finalize(#{name} failed, shall have a template") unless @parent;
		evalUserNodes(self);
	end ##}}}
	
end

## test(name,**opts,&block), describe a test
def test(name,**opts,&block) ##{{{
	c=Test.new(name);
	c.clones(opts[:clones]) if opts.has_key?(:clones);
	c.addUserNode(block);
	MetaData.register(c);
end ##}}}
