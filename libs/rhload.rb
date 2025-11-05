
def rhload fname,visible=false ##{{{
	failed = 1;success = 0;

    ## if visible in arg is false, then set by Rhload's visible config
    ## visible = @visible if visible==false;

	unless (/\.rh/=~fname or /\.rb/=~fname)
		fname += '.rh';
	end

	stacks = (caller(1)[0]).split(':');
	if stacks==nil
		puts ("Error, cannot get caller, no load will execute");
		return failed;
	end
	path = File.dirname(File.absolute_path(stacks[0]));
	## checking if the caller give an relative path
	## load by relative path first
	f = File.join(path,fname);
	if File.exist?(f)
		## puts "DEBUG, load: #{f}";
		load f;
		puts "file #{File.absolute_path(f)} processed" if visible==true;
		return success;
	end

	## checking if the caller gives an abasolute path
	## load directly with the given path+name
	if File.exist?(fname)
		## load directly
		## dir = File.dirname(File.absolute_path(fname));
		## $LOAD_PATH << dir unless $LOAD_PATH.include?(dir);
		## puts "DEBUG, load: #{File.absolute_path(fname)}";
		load fname;
		puts "file #{File.absolute_path(fname)} processed" if visible;
		return success;
	end


	## if not exists by the path, searching with LOAD_PATH
	## load from RUBYLIB
	$LOAD_PATH.each do |p|
		full = File.join(p,fname);
		if File.exist?(full)
			## push dir to LOAD_PATH
			## dir = File.dirname(File.absolute_path(full));
			## $LOAD_PATH << dir unless $LOAD_PATH.include?(dir);
			## puts "DEBUG, load: #{full}";
			load full;
			puts "file #{File.absolute_path(full)} processed" if visible;
			return success;
		end
	end

	raise Exception.new("Error, load failed(file: #{fname} not exists in search path)");

end ##}}}
