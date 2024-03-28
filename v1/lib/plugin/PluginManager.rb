"""
# Object description:
PluginManager, Object to manage all plugins
"""
require 'lib/plugin/Plugin.rb'
class PluginManager ##{{{

	attr :plugins;
	attr :dp;

	BUILT_IN = 'builtin/plugins/node';
	
	## initialize(), 
	def initialize(); ##{{{
		puts "#{__FILE__}:(initialize()) is not ready yet."
		@plugins={};
	end ##}}}

	## init(patcher), 
	# initialize the plugin manager, such like set dispatcher,
	# loading all plugins required.
	def init(patcher,ui); ##{{{
		puts "#{__FILE__}:(init(patcher)) is not ready yet."
		@dp=patcher;
		loading(ui);
	end ##}}}

	## loading(ui), loading required plugins according to ui options.
	# TODO, detailed loading strategy need to be planned.
	def loading(ui); ##{{{
		fromuser = ui.plugins;
		builtin= BUILT_IN;
		#TODO, add display message here.
		rhload builtin;
		fromuser.each do |node|
			rhload node;
		end
	end ##}}}

	# execute all loaded plugins with available steps.
	# called by Rsim.plugins.execute(ui.commands)
	# cmds format: # [{:api=>'build',:opts=>{:config=>:config,:b=>xxx}}]
	def execute(cmds); ##{{{
		puts "#{__FILE__}:(execute(dispatcher)) is not ready yet."
		#1.cmds.each
		#2.self.send(cmd[:api],**cmd[:opts])
		#TODO
	end ##}}}

	## register(p), 
	# register a new loaded plugin into this plugin manager
	def register(p); ##{{{
		@plugins[p.name.to_sym] = p;
		p.dispatcher @dp;
		# define api which described by the plugin obj, so that it can be easily called
		# by the user command from: Rsim.plugins.build(:Config)...
		return unless p.api.has_key?(:block)
		block=p.api[:block];
		name =p.api[:name];
		self.define_singleton_method name.to_sym do |**opts|
			self.instance_eval block,**opts;
		end
	end ##}}}
end ##}}}

## flow(name,&block), description
def flow(name,&block); ##{{{
	name=name.to_sym;
	np = Rsim.plugins.send(name);
	unless np
		np = Plugin.new(name.to_s);
		Rsim.plugins.register(np);
	end
	np.instance_eval &block;
end ##}}}