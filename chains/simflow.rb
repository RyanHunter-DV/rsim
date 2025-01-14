flow :simflow do
	exe :sim

	#generator :build,:selected=>true do
	#	# the build flow, by default is selected
	#	action do
	#		unless option[:skips].include?(:build)
	#			Rsim.info("start generator: sim:build",5);
	#			# 1. find config name from the given test node.
	#			s=Rsim.ipxact.find(option[:suite],:suite);
	#			Rsim.exception(NodeE,:reason=>"test suite(#{option[:suite]}) not declared") unless s;
	#			t=s.find(option[:test],:test);
	#			Rsim.exception(NodeE,:reason=>"test (#{option[:test]}) not declared") unless t;
	#			config=t.config;
	#			#TODO, how to pass through the opts?
	#			Rsim.ipxact.build(:config=>config);
	#		end
	#	end
	#end
	generator :compile,:selected=>true do
		action 'sim' do #TODO, sim exec name shall be replaced later
			unless option[:skip].include?(:compile)
				Rsim.info("start generator: sim:compile",5);
				s=Rsim.ipxact.find(option[:suite],:suite);
				Rsim.exception(NodeE,:reason=>"test suite(#{option[:suite]}) not declared") unless s;
				t=s.find(option[:test],:test);
				Rsim.exception(NodeE,:reason=>"test (#{option[:test]}) not declared") unless t;
				c=t.config; # get config object
				eda=Simulator.new(c.simulator);
				@root=c.outhome;
				option(:eda=>eda,:root=>@root);
				Rsim.info("config outhome(#{@root})",9);
				command %Q|#{eda.exe(:comp)} #{eda.options(:comp)}|;
			end
		end
	end
	generator :elaborate,:selected=>true do
		action 'sim' do
			unless option[:skip].include?(:compile)
				Rsim.info("start generator: sim:elaborate",5);
				#eda=option[:eda];
				#@root=option[:root];
				#Rsim.info("config outhome(#{@root})",9);
				#command %Q|#{eda.exe(:elab)} #{eda.options(:elab)}|;

				s=Rsim.ipxact.find(option[:suite],:suite);
				Rsim.exception(NodeE,:reason=>"test suite(#{option[:suite]}) not declared") unless s;
				t=s.find(option[:test],:test);
				Rsim.exception(NodeE,:reason=>"test (#{option[:test]}) not declared") unless t;
				c=t.config; # get config object
				eda=Simulator.new(c.simulator);
				@root=c.outhome;
				option(:eda=>eda,:root=>@root);
				Rsim.info("config outhome(#{@root})",9);
				command %Q|#{eda.exe(:elab)} #{eda.options(:elab)}|;
			end
		end
	end

end
