# this is the init entry file for generators.
require_relative 'Generator'
require_relative 'GeneratorChain'


# global definition are defined here.
# declare a generator object which will be used
# while parsing the node file.
def generator(name,opts={},&block)
	g=Generator.new(name,opts)
	g.instance_eval(&block) if block_given?;
	RsApp.register_generator(g)
end

# chain command is also a top definition for IP-XACT, so
# a global method is required that users can define its own chain
#
def chain(name,opts={},&block)
	c=GeneratorChain.new(name,opts)
	c.instance_eval(&block) if block_given?;
	RsApp.register_chain(c)
end