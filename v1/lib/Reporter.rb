class Reporter
	# the verbo has 0~9 levels, higher level will have lower priority to
	# print
	attr :threshold
	def initialize(thd=5)
		@threshold = thd;
	end
	def info(msg,verbo=5)
		return if verbo > @threshold;
		pos=caller(2)[0];
		formatted = "[I]#{pos}: #{msg}";
		puts formatted;
		return;
	end
	def error(msg)
		##pos=caller(2)[0];
		formatted = "[E] #{msg}";
		puts formatted;
		return;
	end
end
