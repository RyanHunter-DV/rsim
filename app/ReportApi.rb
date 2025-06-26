require 'printer'
module ReportApi
	@printer = nil
	@debugger = nil

	def debug(message, verbo=5)
		if @debugger.nil?
			puts "[RAW] #{message}"
		else
			@debugger.write(message, verbo,1)
		end
	end

	def info(message, verbo=5)
		if @printer.nil?
			puts "[RAW] #{message}"
		else
			@printer.write(message, verbo,1)
		end
	end

	def debugger
		if @debugger.nil?
			@debugger = Printer.new(10,:D)
		end
		return @debugger;
	end

	def printer
		if @printer.nil?
			@printer = Printer.new(10,:I)
		end
		return @printer;
	end
end