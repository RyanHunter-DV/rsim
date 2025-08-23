generator :compile do
	# VCS compiler generator
	#exe "vcs"
	exe "#{RsApp.ui.rsim_home}/bins/simulator"
	arg :simulator, :value=>'--simulator ${simulator}', :required => true
	#arg :filelist, :value=>'--filelist ${filelist}', :required => true
	#arg :root_dir, :value=>'--root-dir ${root_dir}', :required => true
	arg :out_dir, :value=>'--out-dir ${out_dir}', :required => true
	#arg :compile_options, :value=>'--comp_opt ${compile_options}', :required => false
	arg :full64, :value=>'--full64', :required => false
	arg :compile_only, :value=>'--compile-only', :required => true
	arg :testname, :value=>'--testname ${testname}', :required => true
	arg :remote, :value=>'--remote', :required => false, :switch=>true
	phase 0
end

generator :run do
	# VCS simulation run generator
	exe "#{RsApp.ui.rsim_home}/bins/simulator"
	arg :simulator, :value=>'--simulator ${simulator}', :required => true
	#arg :root_dir, :value=>'--root-dir ${root_dir}', :required => true
	arg :out_dir, :value=>'--out-dir ${out_dir}', :required => true
	#arg :run_options, :value=>'--run_opt ${run_options}', :required => false
	arg :run_only, :value=>'--run-only', :required => true
	arg :testname, :value=>'--testname ${testname}', :required => true
	arg :remote, :value=>'--remote', :required => false, :switch=>true
	phase 2
end

#TODO, generator :clean do
#TODO, 	# VCS cleanup generator
#TODO, 	exe "rm"
#TODO, 	arg :out_dir, :value=>'-rf ${out_dir}/*', :required => false
#TODO, 	phase 3
#TODO, end

# Complete VCS simulation flow
chain :sim do
	generator :compile do
		#param '--simulator'=>ENV['SIMULATOR'] || 'vcs';
		param '--simulator'=>RsApp.ui.options[:simulator];
		#param '--filelist'=>RsApp.ui.options[:filelist];
		#param '--root_dir'=>RsApp.ui.options[:root_dir];
		param '--out-dir'=>RsApp.ui.options[:out_home];
		#param '--compile_options'=>RsApp.ui.options[:comp_opt];
		param '--full64'=>RsApp.ui.options[:full64];
	end
	
	#generator :elaborate do
	#	param '--simulator'=>RsApp.ui.options[:simulator];
	#	#param '--root_dir'=>RsApp.ui.options[:root_dir];
	#	param '--out-dir'=>RsApp.ui.options[:out_home];
	#	#param '--elaborate_options'=>RsApp.ui.options[:elab_opt];
	#	param '--full64'=>RsApp.ui.options[:full64];
	#end
	
	generator :run do
		param '--simulator'=>RsApp.ui.options[:simulator];
		#param '--root_dir'=>RsApp.ui.options[:root_dir];
		param '--out-dir'=>RsApp.ui.options[:out_home];
		#param '--run_options'=>RsApp.ui.options[:run_opt];
	end
end


# VCS compile-only flow
#TODO, chain :vcs_compile_only do
#TODO, 	generator :vcs_compile do
#TODO, 		param '--source_files'=>ENV['SOURCE_FILES'] || '*.sv'
#TODO, 		param '--top_module'=>ENV['TOP_MODULE'] || 'top'
#TODO, 		param '--defines'=>ENV['DEFINES'] || ''
#TODO, 		param '--include_dirs'=>ENV['INCLUDE_DIRS'] || ''
#TODO, 		param '--out_dir'=>File.join(ENV['OUT_HOME'], 'sim')
#TODO, 		param '--compile_options'=>ENV['COMPILE_OPTIONS'] || ''
#TODO, 		param '--full64'=>ENV['FULL64'] || false
#TODO, 		param '--debug'=>ENV['DEBUG'] || false
#TODO, 		param '--verbose'=>ENV['VERBOSE'] || false
#TODO, 	end
#TODO, 	generator :vcs_elaborate do
#TODO, 		param '--top_module'=>ENV['TOP_MODULE'] || 'top'
#TODO, 		param '--out_dir'=>File.join(ENV['OUT_HOME'], 'sim')
#TODO, 		param '--elaborate_options'=>ENV['ELABORATE_OPTIONS'] || ''
#TODO, 		param '--full64'=>ENV['FULL64'] || false
#TODO, 		param '--debug'=>ENV['DEBUG'] || false
#TODO, 		param '--verbose'=>ENV['VERBOSE'] || false
#TODO, 	end
#TODO, end
#TODO, 
#TODO, 
#TODO, # VCS run-only flow
#TODO, chain :vcs_run_only do
#TODO, 	generator :vcs_run do
#TODO, 		param '--testbench'=>ENV['TESTBENCH'] || ''
#TODO, 		param '--run_options'=>ENV['RUN_OPTIONS'] || ''
#TODO, 		param '--verbose'=>ENV['VERBOSE'] || false
#TODO, 		param '--log_file'=>File.join(ENV['OUT_HOME'], 'sim', 'sim.log')
#TODO, 	end
#TODO, end
#TODO, 
#TODO, # VCS clean flow
#TODO, chain :vcs_clean_only do
#TODO, 	generator :vcs_clean do
#TODO, 		param '--out_dir'=>File.join(ENV['OUT_HOME'], 'sim')
#TODO, 	end
#TODO, end 