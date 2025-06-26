
def rhload(entry_file)
	if File.extname(entry_file).empty?
		NodeApp.debug("No extension detected, adding .rh extension to: #{entry_file}", 8)
		entry_file = "#{entry_file}.rh"
		NodeApp.debug("Updated entry_file with .rh extension: #{entry_file}", 8)
	end
	NodeApp.debug("rhload command called with entry_file: #{entry_file}", 8)
	# Check if entry_file is an absolute path
	if entry_file.start_with?('/')
	    NodeApp.debug("Entry file is absolute path, loading directly: #{entry_file}", 8)
	    load(entry_file)
	else
	    # Try relative to current file's directory
	    current_dir = File.dirname(caller_locations(1,1)[0].absolute_path)
	    relative_path = File.join(current_dir, entry_file)
	    NodeApp.debug("Trying relative path: #{relative_path}", 8)
	
	    if File.exist?(relative_path)
	        NodeApp.debug("Found file at relative path: #{relative_path}", 8)
	        load(relative_path)
	    else
	        NodeApp.debug("File not found at relative path: #{relative_path}", 8)
	        raise IpxException.new("Entry file '#{entry_file}' not found relative to current directory")
	    end
	end
end