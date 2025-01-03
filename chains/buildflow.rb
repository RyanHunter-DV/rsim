flow :buildflow do ##{{{

	generator :elaborate,:selected=>true do ##{{{
		#TODO, step to elaborating the loaded nodes by calling the DataBase module's elaborate method.
		action do
			DataBase.elaborate;
		end
	end ##}}}
	generator :finalize,:selected=>true do ##{{{
		action do
			DataBase.finalize;
		end
	end ##}}}

	generator :link,:selected=>false do ##{{{
		#parameter :src => [], :tar => ''
		phase 2.0
		action '/bin/ln' do
			option[:src].each do |s|
				basename=File.basename(s);
				t=File.join(option[:tar],basename)
				command %Q|#{@exec} -s #{s} #{t}|;
			end
		end
	end ##}}}
	generator :copy,:selected=>false do ##{{{
		#parameter :src => [], :tar => ''
		phase 2.0
		action '/bin/cp' do
			option[:src].each do |s|
				basename=File.basename(s);
				t=File.join(option[:tar],basename)
				command %Q|#{@exec} #{s} #{t}|;
			end
		end
	end ##}}}

	#TODO, return needed build generators in a config, return GeneratorExecutor in array format.
	select @config.generators[:buildflow]
end ##}}}