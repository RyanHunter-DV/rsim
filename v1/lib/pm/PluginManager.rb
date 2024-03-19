"""
# Object description:
PluginManager, Object to manage all plugins
"""
require 'lib/pm/Plugin.rb'
class PluginManager ##{{{
	
	## initialize(), 
	def initialize(); ##{{{
		puts "#{__FILE__}:(initialize()) is not ready yet."
	end ##}}}

	## loading(ui), loading required plugins according to ui options.
	# TODO, detailed loading strategy need to be planned.
	def loading(ui); ##{{{
		puts "#{__FILE__}:(loading(ui)) is not ready yet."
		
	end ##}}}

	# execute all loaded plugins with available steps.
	def execute(dispatcher); ##{{{
		puts "#{__FILE__}:(execute(dispatcher)) is not ready yet."
		
	end ##}}}

	## register(p), 
	# register a new loaded plugin into this plugin manager
	def register(p); ##{{{
		puts "#{__FILE__}:(register(p)) is not ready yet."
		# define api which described by the plugin obj, so that it can be easily called
		# by the user command from: Rsim.plugins.build(:Config)...
		self.define_instance_method p.api.to_sym do |**opts|

		end
		
	end ##}}}
end ##}}}

## flow(name,&block), description
def flow(name,&block); ##{{{
	puts "#{__FILE__}:(flow(name,&block)) is not ready yet."
	
	np = Plugin.new(name.to_s);
	Rsim.plugins.register(np);
end ##}}}