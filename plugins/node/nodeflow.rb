require 'ipxact/DataBase.rb' # ipxact db
require 'ipxact/Component.rb'
require 'ipxact/Design.rb'
flow :nodeflow do ##{{{
	#define a new command for component.
	#example: [node/examples/component.rh]
	command :component do |name,opts={},block| ##{{{
		Rsim.info("command: component(#{name},#{opts},#{block})",9)
		c=Component.new(name,opts);
		c.add(block);
		DataBase.register(c,:component);
	end ##}}}
	command :design do |name,opts={},block|
		d=Design.new(name,opts);
		d.add(block);
		DataBase.register(d,:design);
	end
	command :rhloadLocal do |fname,visible=false|

		#failed = 1;success = 0;
		## if visible in arg is false, then set by Rhload's visible config
		## visible = @visible if visible==false;

		unless (/\.rh/=~fname or /\.rb/=~fname)
			fname += '.rh';
		end
		stacks = (caller(1)[0]).split(':');
		if stacks==nil
			Rsim.exception(NodeE,:reason=>"Error, cannot get caller, no load will execute");
		end
		path = File.dirname(File.absolute_path(stacks[0]));
		## checking if the caller give an relative path
		## load by relative path first
		f = File.join(path,fname);
		if Rsim.os.fileExists?(f)
			## puts "DEBUG, load: #{f}";
			load f;
			puts "file #{File.absolute_path(f)} processed" if visible==true;
		elsif Rsim.os.fileExists?(fname)
			## checking if the caller gives an abasolute path
			## load directly with the given path+name
			## load directly
			## dir = File.dirname(File.absolute_path(fname));
			## $LOAD_PATH << dir unless $LOAD_PATH.include?(dir);
			## puts "DEBUG, load: #{File.absolute_path(fname)}";
			load fname;
			Rsim.info("file #{File.absolute_path(fname)} processed",1) if visible;
		else
			## if not exists by the path, searching with LOAD_PATH
			## load from RUBYLIB
			loaded=false;
			$LOAD_PATH.each do |p|
				full = File.join(p,fname);
				if Rsim.os.fileExists?(full)
					## push dir to LOAD_PATH
					## dir = File.dirname(File.absolute_path(full));
					## $LOAD_PATH << dir unless $LOAD_PATH.include?(dir);
					## puts "DEBUG, load: #{full}";
					load full;
					Rsim.info("file #{File.absolute_path(full)} processed",1) if visible;
					loaded=true;break;
				end
			end
			Rsim.exception(NodeE,:reason=>"file not exists in search path(#{fname})") if not loaded;
		end
	end
	# the flow that support loading IP-XACT compatible nodes.
	step :loading do ##{{{
		# TODO, need define a new command for flow.
		Rsim.loadContext self;
		option[:entries].each do |e|
			rhload e;
		end
	end ##}}}
end ##}}}
def rhload(fname,visible=false)
	#failed = 1;success = 0;
	## if visible in arg is false, then set by Rhload's visible config
	## visible = @visible if visible==false;

	unless (/\.rh/=~fname or /\.rb/=~fname)
		fname += '.rh';
	end
	stacks = (caller(1)[0]).split(':');
	if stacks==nil
		Rsim.exception(NodeE,:reason=>"Error, cannot get caller, no load will execute");
	end
	path = File.dirname(File.absolute_path(stacks[0]));
	## checking if the caller give an relative path
	## load by relative path first
	f = File.join(path,fname);
	if Rsim.os.fileExists?(f)
		## puts "DEBUG, load: #{f}";
		#load f;
		fh=File.open(f,'r');
		Rsim.loadContext.instance_eval fh.readlines().join("\n");
		fh.close;
		puts "file #{File.absolute_path(f)} processed" if visible==true;
	elsif Rsim.os.fileExists?(fname)
		## checking if the caller gives an abasolute path
		## load directly with the given path+name
		## load directly
		## dir = File.dirname(File.absolute_path(fname));
		## $LOAD_PATH << dir unless $LOAD_PATH.include?(dir);
		## puts "DEBUG, load: #{File.absolute_path(fname)}";
		#load fname;
		fh=File.open(fname,'r');
		Rsim.loadContext.instance_eval fh.readlines().join("\n");
		fh.close;
		Rsim.info("file #{File.absolute_path(fname)} processed",1) if visible;
	else
		## if not exists by the path, searching with LOAD_PATH
		## load from RUBYLIB
		loaded=false;
		$LOAD_PATH.each do |p|
			full = File.join(p,fname);
			if Rsim.os.fileExists?(full)
				## push dir to LOAD_PATH
				## dir = File.dirname(File.absolute_path(full));
				## $LOAD_PATH << dir unless $LOAD_PATH.include?(dir);
				## puts "DEBUG, load: #{full}";
				#load full;
				fh=File.open(full,'r');
				Rsim.loadContext.instance_eval fh.readlines().join("\n");
				fh.close;
				Rsim.info("file #{File.absolute_path(full)} processed",1) if visible;
				loaded=true;break;
			end
		end
		Rsim.exception(NodeE,:reason=>"file not exists in search path(#{fname})") if not loaded;
	end
end