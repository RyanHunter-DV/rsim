module Rsim

	## self.init, tool initialization
	def self.init; ##{{{
		#puts "#{__FILE__}:(self.init) is not ready yet."
		@pm=PluginManager.new;
		@config=RsimConfig.new;
	end ##}}}

	## self.run, 
	# running the main tool
	def self.run; ##{{{
		puts "#{__FILE__}:(self.run) is not ready yet."
		# 1.call self.init that can automatically initialize.
		# 2.plugins dynamic loading
		self.loadPlugins;
	end ##}}}

	## self.loadPlugins, 
	def self.loadPlugins; ##{{{
		#puts "#{__FILE__}:(self.loadPlugins) is not ready yet."
		@pm.dynamicLoading(@config.requiredPlugins,@config.pluginPaths);
	end ##}}}
end