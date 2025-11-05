class Printer ##{{{

    attr_accessor :verbosity, :severity;
    attr :action;
    attr :log_file;

    attr :enabled;
    def initialize _v=5, _s=:DEBUG, _log_file=nil ##{{{
        @verbosity = _v;
        @severity = _s;
        @action={:display=>true};
        @enabled = true;
        if _log_file != nil
            @log_file = File.open(_log_file, "w");
            @action[:log] = true;
        end
    end ##}}}

    def enable(v)
        @enabled = v;
    end
    def open_log(log_file)
        @log_file = File.open(log_file, "w");
        @action[:log] = true;
    end

    def close
        if @log_file
            @log_file.flush;@log_file.close
        end
    end

    # current support :log
    # :display is supported by default
    def action(name)
        @action[name] = true;
    end
	## set_verbosity(v), description
	def set_verbosity(v) ##{{{
		@verbosity=v;
	end ##}}}
    # deprecated method.
    def >(msg, v=0) ##{{{
        # for debug, the verbosity must >= 5
        v+=5 if @severity == :DEBUG;
		caller_info = caller(1).first
		message = "[#{caller_info}] #{msg}"
        puts "[#{@severity}] "+message if v < @verbosity && @action && @action.has_key?(:display);
        if v < @verbosity && @action && @action.has_key?(:log)
            @log_file.write("[#{@severity}] #{message}\n")
        end
    end ##}}}
    def write(msg, v=0,depth=0) ##{{{
        return if !@enabled;
		depth+=1;
        # for debug, the verbosity must >= 5
        v+=5 if @severity == :DEBUG;
		caller_info = "[#{caller(depth).first}]";
		caller_info='' if @severity!=:D and @severity!=:DEBUG;
		message = "#{caller_info}(#{Time.now.strftime("%H:%M:%S")}) #{msg}"
        puts "[#{@severity}] "+message if v < @verbosity && @action && @action.has_key?(:display);
        if v < @verbosity && @action && @action.has_key?(:log)
            @log_file.write("[#{@severity}] #{message}\n")
            @log_file.flush
        end
    end ##}}}
end ##}}}
