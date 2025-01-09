flow :buildflow do

	exe :build

	generator :elaborate,:selected=>true do ##{{{
		#TODO, step to elaborating the loaded nodes by calling the DataBase module's elaborate method.
		action do
			Rsim.ipxact.elaborate;
		end
	end ##}}}
	generator :finalize,:selected=>true do ##{{{
		action do
			Rsim.ipxact.finalize;
		end
	end ##}}}

	generator :link,:selected=>false do ##{{{
		phase 2.0
		action '/bin/ln' do
			option[:src].each do |s|
				basename=File.basename(s);
				t=File.join(option[:tar],basename)
				Rsim.info("generator(link) action command: #{@exec} -s #{s} #{t}");
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

	# need pass the config object into chain
	# config.components is the needed components
	#@config.components.each do |c|
	#	select c.generator,c.generatorOptions
	#end
end
