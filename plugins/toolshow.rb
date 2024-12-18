flow :toolshow do ##{{{
	step :help do ##{{{
		Rsim.info("display help message for tool")
		puts "\n"
		puts option[:message];
		puts "\n"
	end ##}}}
	step :version do ##{{{
		Rsim.info("tool generation 2");
	end ##}}}
end ##}}}