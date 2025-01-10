flow :buildflow do
	exe :build
	generator :elaborate,:selected=>true do ##{{{
		action do
			Rsim.info("execute generator buildflow:elaborate");
			Rsim.ipxact.elaborate;
		end
	end ##}}}
	generator :finalize,:selected=>true do ##{{{
		action do
			Rsim.info("execute generator buildflow:finalize");
			Rsim.ipxact.finalize;
		end
	end ##}}}
	generator :link,:selected=>false do ##{{{
		phase 2.0
		action '/bin/ln' do
			Rsim.info("execute generator buildflow:link");
			@root= option[:tar];
			option[:src].each do |s|
				Rsim.info("given src file: #{s}",9);
				basename=File.basename(s);
				t=File.join(option[:tar],basename)
				Rsim.os.mkdir(option[:tar],:recursive=>true) unless Rsim.os.exists?(:dir,option[:tar]);
				Rsim.info("generator(link) action command: #{exe} -s #{s} #{t}");
				command %Q|#{exe} -s #{s} #{t}|;
			end
		end
	end ##}}}
	generator :copy,:selected=>false do ##{{{
		#parameter :src => [], :tar => ''
		phase 2.0
		action '/bin/cp' do
			Rsim.info("execute generator buildflow:copy");
			@root= option[:tar];
			option[:src].each do |s|
				basename=File.basename(s);
				t=File.join(option[:tar],basename)
				Rsim.os.mkdir(option[:tar],:recursive=>true) unless Rsim.os.exists?(:dir,option[:tar]);
				command %Q|#{exe} #{s} #{t}|;
			end
		end
	end ##}}}
end
