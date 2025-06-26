class Generator

	# the unique identifier for recognized by other classes.
	attr_accessor :name;

	attr :exe;

	attr :args;
	attr :phase;

	def initialize(name,opts={})
		@name=name.to_s;
		@args={};
		@exe=nil;
		@phase=0;
	end

	def exe(cmd=nil)
		return @exe if cmd.nil?;
		@exe=cmd;
	end
	def phase(phase=nil)
		return @phase if phase.nil?;
		@phase=phase;
	end

	# id is the unique identifier for the argument.
	# :value => 'xxx', gives a string which contains option name and format.
	# the ${xxx} in the value string indicates a variable that will be replaced by chain or chain configuration.
	# :type => :xxx, used to specify the type of the arg, is a switch, or string or array for multiple times input
	# :required => true, used to specify the argument is required or not.
	def arg(id,opts={})
		@args[id.to_sym]=opts;
	end


	def execute(params)
		RsApp.debug("Executing generator #{@name} with params #{params}", 5)
		cmd_args = []
		@args.each do |id, opts|
			value = opts[:value]
			if value
				value.gsub!(/\$\{(\w+)\}/) do |match|
					param_key = id.to_sym;
					if params.has_key?(param_key)
						params[param_key].to_s
					else
						RsApp.info("Warning: Parameter #{param_key} not found, using empty string", 3)
						""
					end
				end
				cmd_args << value
			end
		end
		cmd=%Q|#{@exe} #{cmd_args.join(' ')}|
		RsApp.debug("Executing command: #{cmd}", 5)
		job = MjsCommand.new(:external,self,cmd)
		return RsApp.mj.dispatch(job)
	end

end