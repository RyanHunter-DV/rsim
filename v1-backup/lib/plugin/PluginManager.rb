"""
# Object description:
PluginManager, Object to manage all plugins
"""
require 'lib/plugin/Plugin.rb'
class PluginManager

	attr_accessor :plugins;
	attr :dp;

	BUILT_INS = 'builtin/plugins/node.rh;builtin/generators/build.rh';
	
	## initialize(), 
	def initialize(patcher,options); ##{{{
		@plugins={};
		@dp=patcher;
		loading(options);
	end ##}}}

	## loading(ui), loading required plugins according to ui options.
	# TODO, detailed loading strategy need to be planned.
	def loading(ui); ##{{{
		fromuser = ui.plugins;
		builtins= BUILT_INS.split(';');
		builtins.each do |builtin|
			Rsim.info("loading builtin plugin node(#{builtin})",6);
			rhload builtin,:tool;
		end
		fromuser.each do |node|
			rhload node;
		end
	end ##}}}

	#TODO, deprecated, # execute all loaded plugins with available steps.
	#TODO, deprecated, # called by Rsim.plugins.execute(ui.commands)
	#TODO, deprecated, # cmds format: # [{:api=>'build',:opts=>{:config=>:config,:b=>xxx}}]
	#TODO, deprecated, def execute(cmds); ##{{{
	#TODO, deprecated, 	Rsim.info("call execute(#{cmds})",6);
	#TODO, deprecated, 	#puts "#{__FILE__}:(execute(dispatcher)) is not ready yet."
	#TODO, deprecated, 	#1.cmds.each
	#TODO, deprecated, 	cmds.each do |cmd|
	#TODO, deprecated, 		#2.self.send(cmd[:api],**cmd[:opts])
	#TODO, deprecated, 		Rsim.info("executing command(#{cmd[:api]},#{cmd[:opts]})");
	#TODO, deprecated, 		self.send(cmd[:api],**cmd[:opts]);
	#TODO, deprecated, 	end
	#TODO, deprecated, 	#TODO
	#TODO, deprecated, end ##}}}

	## execute(plugin,*args), execute api called by other components to execute the specified
	# plugin with given args:
	# Rsim.pm.execute(:buildflow,:ConfigName)
	def execute(plugin,**opts); ##{{{
		Rsim.info("executing plugin(#{plugin}),options(#{opts})");
		# call of plugin will call the api defined while a new plugin registered in PluginManager
		self.send(plugin.to_sym,**opts);
	end ##}}}


	## register(p), 
	# register a new loaded plugin into this plugin manager
	def register(p); ##{{{
		@plugins[p.name.to_sym] = p;
		p.dispatcher= @dp;
		# define api which described by the plugin obj, so that it can be easily called
		# by the user command from: Rsim.plugins.build(:Config)...
		Rsim.info("register plugin:#{p.name}",9);
		p.container=self;
		self.define_singleton_method p.name.to_sym do |**opts|
			p.run(**opts);
		end
	end ##}}}
end

## flow(name,&block), description
def flow(name,&block); ##{{{
	name=name.to_sym;
	np=nil;
	Rsim.info("defining flow: #{name}",9);
	if Rsim.pm.respond_to?(name);
		Rsim.info("add new block into previously registered plugin",9);
		np=Rsim.pm.send(name);
	else
		Rsim.info("create a new plugin object",9);
		np = Plugin.new(name.to_s);
		Rsim.pm.register(np);
		Rsim.info("#{np} registered",9);
		Rsim.info("#{np.name} registered",8);
	end
	np.instance_eval &block;
end ##}}}
