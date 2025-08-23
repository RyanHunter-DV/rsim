#command :config do |name,&block|
def config(name,&block)
	#node_path = File.absolute_path(File.dirname(__FILE__))
	node_path = File.dirname(block.source_location[0]);
	c = Config.new(name,node_path);
	# first register to get the design instance, then to call block evaluation
	NodeApp.meta.link_design(c);
	c.instance_eval(&block);
	NodeApp.meta.register('config',c);
end

#command :component do |name,&block|
def component(name,&block)
	# ip xact component, create a Component instance, eval the block and register to self.meta
	# self should be buildflow.
	#node_path = File.absolute_path(File.dirname(__FILE__))
	node_path = File.dirname(block.source_location[0]);
	c = Component.new(name,node_path);
	NodeApp.debug("execute component command with args: #{name},#{block.inspect}")
	c.instance_eval(&block);
	NodeApp.meta.register('component',c);
	NodeApp.info("Component #{name} registered", 8)
end
#command :design do |name,&block|
def design(name,&block)
	#node_path = File.absolute_path(File.dirname(__FILE__))
	node_path = File.dirname(block.source_location[0]);
	d = Design.new(name,node_path);
	d.instance_eval(&block);
	NodeApp.meta.register('design',d);
end

def suite(name,&block)
	node_path = File.dirname(block.source_location[0]);
	s = TestSuite.new(name,node_path);
	s.instance_eval(&block);
	NodeApp.meta.register('suite',s);
end
