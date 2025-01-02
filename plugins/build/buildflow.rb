flow :buildflow do ##{{{

	generator :elaborate do ##{{{
		#TODO, step to elaborating the loaded nodes by calling the DataBase module's elaborate method.
		action do
			DataBase.elaborate;
		end
	end ##}}}
	generator :finalize do ##{{{
		action do
			DataBase.finalize;
		end
	end ##}}}

	generator :link do ##{{{
		#parameter :src => [], :tar => ''
		phase 2.0
		action '/bin/ln' do
			args(:src).each do |s|
				basename=File.basename(s);
				t=File.join(args(:tar),basename)
				command %Q|#{@exec} -s #{s} #{t}|;
			end
		end
	end ##}}}
	generator :copy do ##{{{
		#parameter :src => [], :tar => ''
		phase 2.0
		action '/bin/cp' do
			args(:src).each do |s|
				basename=File.basename(s);
				t=File.join(args(:tar),basename)
				command %Q|#{@exec} #{s} #{t}|;
			end
		end
	end ##}}}

	#TODO, return needed build generators in a config, return GeneratorExecutor in array format.
	select @config.generators[:buildflow]
end ##}}}