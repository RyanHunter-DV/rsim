"""
# Object description:
PluginManager, Object to manage all plugins
"""
require 'lib/plugin/Plugin.rb'
class PluginManager

	attr_accessor :plugins;
	attr :dp;

	BUILT_IN = 'builtin/plugins/node.rh';
	
	## initialize(), 
	def initialize(); ##{{{
		@plugins={};
		#init(dp,ui);
	end ##}}}

	## init(patcher), 
	# initialize the plugin manager, such like set dispatcher,
	# loading all plugins required.
	def init(patcher,ui); ##{{{
		@dp=patcher;
		loading(ui);
	end ##}}}

	## loading(ui), loading required plugins according to ui options.
	# TODO, detailed loading strategy need to be planned.
	def loading(ui); ##{{{
		fromuser = ui.plugins;
		builtin= BUILT_IN;
		Rsim.info("loading builtin plugin node(#{builtin})",6);
		rhload builtin,:tool;
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
		p.dispatcher= @dp;
		# define api which described by the plugin obj, so that it can be easily called
		# by the user command from: Rsim.plugins.build(:Config)...
		Rsim.info("register plugin, api:#{p.api}",9);
		p.container=self;
		#return unless p.api.has_key?(:proc)
		#block=p.api[:proc];
		#name =p.api[:name];
	end ##}}}
end

## flow(name,&block), description
def flow(name,&block); ##{{{
	name=name.to_sym;
	np=nil;
	Rsim.info("defining flow: #{name}",9);
	if Rsim.pm.respond_to?(name);
		Rsim.info("in branch 1",9);
		np=Rsim.pm.send(name);
	else
		Rsim.info("in branch 2",9);
		np = Plugin.new(name.to_s);
		Rsim.pm.register(np);
		Rsim.info("#{np} registered",9);
		Rsim.info("#{np.name} registered",8);
	end
	np.instance_eval &block;
end ##}}}
