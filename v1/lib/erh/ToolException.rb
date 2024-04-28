class ToolException < Exception
	attr :message;
	attr :stack;
	def initialize(msg)
		@message = msg;
		@stack = caller(2);
	end
	def process
		Rsim.error(@message);
		puts @stack;
		exit 4;
	end
end
