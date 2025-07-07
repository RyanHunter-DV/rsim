generator :node_load do
	# generate to load all nodes compatibale with IP-XACT and build to xml baed meta data
	exe "#{ENV['RSIM_HOME']}/bins/node_load"
	arg :out,:value=>'--out ${out}', :required => true
	arg :entry,:value=>'--entry ${entry}', :required => true
	arg :verbosity,:value=>'--verbosity ${verbosity}', :required => false
	arg :debug,:value=>'--debug ${debug}', :required => false
	phase 0
end
generator :file_build do
	# generate to link all nodes compatibale with IP-XACT and build to xml baed meta data
	exe "#{ENV['RSIM_HOME']}/bins/builder"
	arg :config,:value=>'--config ${config}', :required => true
	arg :out,:value=>'--out ${out}', :required => true
#	arg :builder,:value=>'--rtl', :required => true
	arg :method,:value=>'--method link', :required => true
	phase 1
end
#generator :dv_build do
#	#generator to build dv files according to the config in db.
#	exe "#{ENV['RSIM_HOME']}/bins/builder"
#	arg :config,:value=>'--config ${config}', :required => true
#	arg :out,:value=>'--out ${out}', :required => true
#	arg :builder,:value=>'--dv', :required => true
#	arg :method,:value=>'--method link', :required => true
#	phase 1
#end
chain :build do
	generator :node_load do
		param '--out'=>ENV['OUT_HOME']
		param '--entry'=>ENV['RSIM_ENTRY']
		param '--verbosity'=>10
		param '--debug'=>10
	end
	generator :file_build do
		param '--out'=>ENV['OUT_HOME']
	end
	#generator :dv_build do
	#	param '--out'=>ENV['OUT_HOME']
	#end
end