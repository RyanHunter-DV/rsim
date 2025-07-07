# This is the class for describing the Flow object that created by the global flow command.
require_relative 'RsAction'
class RsFlow

	attr :actions;
	attr :current_phase;
	attr :predecessor;
	attr_reader :name;
	def initialize(name)
		RsApp.debug("Initializing RsFlow with name: #{name}", 3)
		@name = name.to_sym;
		@actions = [];
		@current_phase = -1;
		@predecessor = nil;
		RsApp.debug("RsFlow initialized: #{@name} with #{@actions.length} actions", 3)
	end

	def this
		return self;
	end

	def predecessor(name=nil)
		if name.nil?
			RsApp.debug("Getting predecessor for flow: #{@name} -> #{@predecessor}", 4)
			return @predecessor;
		end
		RsApp.debug("Setting predecessor for flow: #{@name} -> #{name}", 4)
		@predecessor = name.to_sym;
	end

	# support commands by declaring a new flow:
	# ui, to setup new user options, for example
	# ui :rsim_entry,:type => :string,:description => "rsim root.rh file as the entry of buildflow"
	def ui(name,opts)
		RsApp.debug("Adding UI option: #{name} for flow: #{@name}", 4)
		opts[:flow_name] = @name;
		RsApp.ui.add_option(name,opts)
		RsApp.debug("UI option added: #{name}", 4)
	end

	# required env for the flow. for example:
	# env :rsim_entry,:is_mandatory => true do - end
	# code block can be used to update the instance variable @{name}
	def env(name,opts,&block)
		RsApp.debug("Processing environment variable: #{name} for flow: #{@name}", 4)
		env_value = ENV[name.to_s.upcase]
		RsApp.debug("Environment value for #{name}: #{env_value.nil? ? 'nil' : env_value}", 4)
		
		if opts[:is_mandatory]
			# Check if environment variable is defined
			if env_value.nil? || env_value.empty?
				RsApp.debug("Mandatory environment variable #{name.to_s.upcase} is missing", 3)
				raise UIException.new("Mandatory environment variable #{name.to_s.upcase} is not defined")
			end
			RsApp.debug("Mandatory environment variable #{name.to_s.upcase} validated", 4)
		end
		
		instance_variable_set("@#{name}", env_value)
		RsApp.debug("Set instance variable @#{name} = #{env_value.nil? ? 'nil' : env_value}", 4)
		instance_eval(&block) if block_given?
		RsApp.debug("Environment processing completed for: #{name}", 4)
	end

	# action, to declare a new RsAction object.
	def action(action_name=nil,step_name=nil,&block)
		action_name ||= "action_#{@actions.length+1}";
		step_name ||= 'default_step';
		RsApp.debug("Creating action: #{action_name} in step: #{step_name} for flow: #{@name}", 4)
		action = RsAction.new(action_name,step_name,self)
		action.instance_eval(&block)
		@actions << action
		RsApp.debug("Action created and added: #{action_name} (total actions: #{@actions.length})", 4)
	end

	# api for flow to define a new command that can be used in their actions.
	# command definition in user flow will be evaluated first before calling actions.
	def command(name,opts={},&block)
		RsApp.debug("Defining command: #{name} for flow: #{@name}", 4)
		define_singleton_method(name.to_sym) do |*args,&b|
			RsApp.debug("Executing command: #{name} with args: #{args.inspect}", 5)
			block.call(*args,&b) if block_given?
		end
		RsApp.debug("Command defined: #{name}", 4)
	end

	def has_next_phase?
		next_phases = @actions.map(&:phase).select { |phase| phase > @current_phase }
		has_next = !next_phases.empty?
		RsApp.debug("has_next_phase? for flow #{@name}: #{has_next} (current: #{@current_phase}, next phases: #{next_phases})", 4)
		has_next
	end

	def next_phase
		RsApp.debug("Getting next phase for flow: #{@name} (current: #{@current_phase})", 4)
		next_phases = @actions.map(&:phase).select { |phase| phase > @current_phase }
		if next_phases.empty?
			RsApp.debug("No next phases available for flow: #{@name}", 4)
			return []
		end
		min_phase = next_phases.min
		@current_phase = min_phase
		phase_actions = @actions.select { |action| action.phase == min_phase }
		RsApp.debug("Next phase #{min_phase} for flow #{@name} with #{phase_actions.length} actions", 4)
		phase_actions
	end

end


# global command to create a flow object.
def flow(name,&block)
	flow_name="#{name}flow";
	o=RsFlow.new(flow_name);
	o.instance_eval(&block);
	RsApp.debug("Registering flow: #{o.name}", 5)
	RsApp.pm.register_flow(o);
end