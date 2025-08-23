require 'mjs/MjsCommand'
class RsAction
	# action belongs to a certain step name, if not specified, the step_name is 'default_step'
	attr :step_name;
	attr :phase;
	attr :command;
	attr :action_name;

	attr :container;
	def initialize(action_name,step_name,container)
		@action_name = action_name;
		@step_name = step_name || 'default_step';
		@phase = 0;
		@command = {:type=>nil,:cmd=>nil,:context=>nil};
		@container = container;
	end

	# action block supports command:
	# action do
	# 1. phase, specify a real phase number.
	# 2. command :external do-end, external command will give a string in code block, internal will given a block for executing.
	# end
	def phase(number=nil)
		return @phase if number.nil?;
		@phase = number;
	end

	def context
		return @command[:context];
	end

	def command(type,context,&block)
		@command[:type] = type.to_sym;
		if @command[:type] == :external
			@command[:cmd] = self.instance_eval(&block)
		elsif @command[:type] == :internal
			@command[:context] = context;
			@command[:cmd] = lambda do |*args|
				begin
					block.call
					0
				rescue Exception => e
					message = "Error in internal command: #{e.message}"
					message += "\nBacktrace: #{e.backtrace.join("\n")}"
					message
				end
			end
		else
			raise "Invalid command type: #{type}"
		end
	end

	def job
		#TODO, to generate the MjsCommand object for the action.
		j= MjsCommand.new(@command[:type],@command[:context],@command[:cmd]);
		return j;
	end

	# the action object need to copy variables from the super flow object.
	def copy_variable(key)
		instance_variable_set("@#{key}",@container.instance_variable_get("@#{key}"))
	end

	def method_missing(method_name, *args, &block)
		RsApp.debug("Method missing: #{method_name} in RsAction, delegating to container", 8)
		@container.send(method_name, *args, &block)
	end
end