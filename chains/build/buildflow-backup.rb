# # build flow features:
# collect all specified node.rh and root.rh config files.
# so it required a ui option named rsim_entry to get all root.rh files.
#

require_relative 'ipxact/database'
require_relative 'ipxact/xmls/init'
flow :build do
	RsApp.debug("Initializing build flow", 8)

	env :rsim_entry,:is_mandatory => true do
		RsApp.debug("Processing rsim_entry environment variable", 8)
		if @rsim_entry.include?(';')
			@rsim_entry = @rsim_entry.split(';') 
		else
			@rsim_entry = [@rsim_entry]
		end
		RsApp.debug("rsim_entry processed: #{@rsim_entry.inspect}", 8)
	end

	# Get current file's absolute directory
	current_dir = File.expand_path(File.dirname(__FILE__))
	RsApp.debug("Current file directory: #{current_dir}", 8)
	# Find all *.rh files in the current directory
	#rh_files = `find #{current_dir} -name "rhload.rh"`.split("\n")
	#rh_files += `find #{current_dir} -name "init.rh"`.split("\n")
	rh_files = [
		'rhload.rh',
		'actions.rh',
		'ipxact/IpxBaseObject.rh',
		'ipxact/file_set.rh',
		'ipxact/view.rh',
		'ipxact/component.rh',
		'ipxact/config.rh',
		'ipxact/design.rh',
	]
	# Instance_eval the read contents of each .rh file
	rh_files.each do |rh_file|
		rh_file = File.join(current_dir, rh_file)
		RsApp.debug("Processing .rh file: #{rh_file}", 8)
		file_content = File.read(rh_file)
		RsApp.debug("Read content from #{rh_file}, length: #{file_content.length}", 8)
		self.instance_eval(file_content, rh_file)
		RsApp.debug("Successfully evaluated content from: #{rh_file}", 8)
	end

	self.instance_variable_set(:@node_path,nil);

	RsApp.debug("Setting up meta database for #{self.name}", 8)
	# setup meta_database, which will be used to store all IP-XACT based information.
	RsApp.debug("Creating new MetaDatabase instance", 8)
	self.instance_variable_set(:@meta_database,MetaDatabase.new(RsApp.ui.out_home));
	self.define_singleton_method(:meta) do
		RsApp.debug("Using existing MetaDatabase instance", 8)
		return @meta_database;
	end
	RsApp.debug("Meta database setup completed, #{self.methods}", 8)
	RsApp.debug("Build flow initialization completed", 8)


end