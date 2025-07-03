class IpxException < Exception
	attr_accessor :level
	attr_accessor :message
	def initialize(message,level=0)
		@message = message;
		@level = level;
	end
end

class EdaException < Exception
	attr_accessor :level
	attr_accessor :message
	def initialize(message,level=0)
		@message = message;
		@level = level;
	end
end