require_relative 'RsFlow'
class PluginManager
	attr :skip_list;
	attr :plugins;
	attr :scheduler;
	attr :plugin_dir;
	def initialize
		RsApp.debug("Initializing PluginManager", 8)
		@plugins = {}
		@skip_list = {:step=>[],:action=>[],:flow=>[]}
		@plugin_dir = File.join(RsApp.root_dir,"flows");
		RsApp.debug("PluginManager initialized with plugin_dir: #{@plugin_dir}", 8)
		@scheduler = [];
	end

	def load_flow_file(flow_name)
		RsApp.debug("load_flow_file called with flow_name: #{flow_name}", 8)
		flow_file = "#{flow_name}.rb"
		RsApp.debug("Searching for flow file: #{flow_file} in #{@plugin_dir}", 5)
		
		# Use system find command to search for the flow file
		find_result = `find "#{@plugin_dir}" -name "#{flow_file}" 2>/dev/null`.strip
		RsApp.debug("Find command result: #{find_result}", 8)
		
		if find_result.empty?
			RsApp.debug("Flow file not found, raising exception", 8)
			raise "Flow file not found: #{flow_file} in #{@plugin_dir}"
		end
		
		# Use the first result found
		flow_file_path = find_result.lines.first.strip
		RsApp.debug("Loading flow file: #{flow_file_path}", 5)
		load flow_file_path
		RsApp.debug("Flow file loaded: #{flow_file_path}", 5)
	end

	def load_plugins(flows)
		RsApp.debug("load_plugins called with flows: #{flows.inspect}", 8)
		# 1. to figure out all dependencies of the flows.
		# 2. to load the plugins in the correct order.
		flows.each_pair do |flow_name,flow_options|
			flow_name = flow_name.to_sym;
			RsApp.debug("Processing flow: #{flow_name} with options: #{flow_options.inspect}", 8)
			# call load first to load the flow file
			load_flow_file(flow_name);
			flow = @plugins[flow_name];
			RsApp.debug("Retrieved flow from plugins: #{flow.inspect}", 8)
			if !flow.predecessor.nil?
				RsApp.debug("Loading predecessor for flow: #{flow_name}", 8)
				load_plugins(flow.predecessor)
			end
			@scheduler << flow;
			RsApp.info("Loaded flow: #{flow.name} ", 5)
		end
		RsApp.debug("load_plugins completed", 8)
	end

	def register_flow(flow)
		RsApp.debug("register_flow called with flow: #{flow.name}", 8)
		@plugins[flow.name] = flow;
		RsApp.debug("Flow registered: #{flow.name}", 8)
	end
	
	def skip?(name,t=:step)
		RsApp.debug("skip? called with name: #{name}, type: #{t}", 8)
		#TODO, check if given t is skipped
		# t can be :step, :action, :flow,
		# different t will search from different list for the given name
		skip_result = @skip_list[t.to_sym].include?(name)
		RsApp.debug("Skip check result for #{name} (#{t}): #{skip_result}", 8)
		return true if skip_result;
		return false;
	end

	def run_plugins
		RsApp.debug("Starting plugin execution", 5)
		#1.@scheduler is the ordered list to run the registered plugins, some of plugins may be registered but need to skip.
		@scheduler.each do |plugin|
			RsApp.debug("Processing plugin: #{plugin.name}", 7)
			if skip?(plugin.name,:flow)
				RsApp.debug("Skipping plugin: #{plugin.name}", 8)
				next
			end
			RsApp.debug("Plugin #{plugin.name} not skipped, executing phases", 8)
			while plugin.has_next_phase?
				RsApp.debug("Starting new phase for plugin: #{plugin.name}", 9)
				ps=[];
				plugin.next_phase.each do |action|
					RsApp.debug("Processing action: #{action.action_name} in step: #{action.step_name}", 10)
					# action is different than the MjsCommand, which require more information for flow running.
					# so the action object will have the MjsCommand object which call be called by .job method.
					if skip?(action.step_name) or skip?(action.action_name,:action)
						RsApp.debug("Skipping action: #{action.action_name} (step: #{action.step_name})", 8)
					else
						RsApp.debug("Dispatching job for action: #{action.action_name}", 9)
						ps<<RsApp.mj.dispatch(action.job)
					end
				end
				RsApp.debug("Awaiting #{ps.length} jobs for plugin: #{plugin.name}", 8)
				RsApp.mj.await(ps);
			end
		end
		RsApp.debug("Plugin execution completed", 5)
	end
end
