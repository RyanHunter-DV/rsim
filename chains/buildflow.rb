flow :buildflow do
	exe :build
	generator :finalize,:selected=>true do ##{{{
		action do
			Rsim.info("start generator: build:finalize");
			cn=nil;
			cn=option[:config] if option.has_key?(:config);
			if cn==nil
				s=Rsim.ipxact.find(option[:suite],:suite);
				Rsim.exception(NodeE,:reason=>"test suite(#{option[:suite]}) not declared") unless s;
				t=s.find(option[:test],:test);
				Rsim.exception(NodeE,:reason=>"test (#{option[:test]}) not declared") unless t;
				c=t.config;
				Rsim.info("getting config(#{c}) from test(#{t.id})",9);
			end
			Rsim.ipxact.finalize(c.id);
		end
	end ##}}}
	generator :link,:selected=>false do ##{{{
		phase 2.0
		action '/bin/ln' do
			Rsim.info("start generator build:link");
			@root= option[:tar];
			option[:src].each do |s|
				Rsim.info("given src file: #{s}",9);
				basename=File.basename(s);
				t=File.join(option[:tar],basename)
				Rsim.os.mkdir(option[:tar],:recursive=>true) unless Rsim.os.exists?(:dir,option[:tar]);
				Rsim.info("generator(link) action command: #{exe} -s #{s} #{t}");
				Rsim.ipxact.config.filelist t;
				command %Q|#{exe} -s #{s} #{t}|;
			end
		end
	end ##}}}
	generator :copy,:selected=>false do ##{{{
		#parameter :src => [], :tar => ''
		phase 2.0
		action '/bin/cp' do
			Rsim.info("start generator build:copy");
			@root= option[:tar];
			option[:src].each do |s|
				basename=File.basename(s);
				t=File.join(option[:tar],basename)
				Rsim.os.mkdir(option[:tar],:recursive=>true) unless Rsim.os.exists?(:dir,option[:tar]);
				Rsim.ipxact.config.filelist t;
				command %Q|#{exe} #{s} #{t}|;
			end
		end
	end ##}}}
end
