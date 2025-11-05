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
			switch=opts[:switch] || false;
			if value
				if switch
					if params.has_key?(value)
						cmd_args << opts[:value]
					end
				else
					# Find pattern: prefix and ${xxx}
					if value =~ /(\S+)\s+\$\{(\w+)\}/
						prefix = $1
						param_key = $2.to_s
						if params.has_key?(prefix)
							param_values = params[prefix]
							#param_values = [param_values] unless param_values.is_a?(Array)
							param_values.each do |item|
								cmd_args << "#{prefix} #{item}"
							end
						else
							RsApp.info("Warning: Parameter #{param_key} not found, using empty string", 3)
							cmd_args << "#{prefix} "
						end
					else
						cmd_args << value
					end
				end
			end
		end
		cmd=%Q|#{@exe} #{cmd_args.join(' ')}|
		#exit 3;
		RsApp.debug("Executing command: #{cmd}", 5)
		job = MjsCommand.new(:external,self,cmd)
		return RsApp.mj.dispatch(job)
	end

end