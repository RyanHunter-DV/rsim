require 'ipxact/Component.rb'
require 'ipxact/Design.rb'
require 'ipxact/BusDefinition.rb'
require 'ipxact/Abstraction.rb'
flow :nodeflow do

	exe :node # set the execute name

	# command to describe a busDefinition
	command :bus do |vlnv,opts={},block|
		o=BusDefinition.new(vlnv);
		o.instance_eval &block;
		Rsim.ipxact.register(o,:busDefinition);
	end
	# use this command to declare an abstraction
	command :abstraction do |vlnv,opts={},block|
		o=AbstractionDefinition.new(vlnv);
		o.instance_eval &block;
		Rsim.ipxact.register(o,:abstraction);
	end
	#define a new command for component.
	#example: [node/examples/component.rh]
	command :component do |name,opts={},block|
		info("command: component(#{name},#{opts},#{block})",9)
		c=Component.new(name,opts);
		c.root=File.absolute_path(File.dirname(Rsim.loadingNode));
		c.instance_eval &block;
		Rsim.ipxact.register(c,:component);
	end
	command :design do |name,opts={},block|
		d=Design.new(name,opts);
		d.add(block);
		Rsim.ipxact.register(d,:design);
	end
	command :config do |name,opts={},block|
		info("command: config(#{name},#{opts},#{block})",9);
		c=Config.new(name,opts);
		c.instance_eval &block;
		Rsim.ipxact.register(c,:config);
	end
	# the flow that support loading IP-XACT compatible nodes.
	generator :loading,:selected=>true do ##{{{
		action do
			Rsim.loadContext self;
			Rsim.info("load context: #{Rsim.loadContext}")
			option[:entries].each do |e|
				rhload e;
			end
		end
	end ##}}}
end
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
		Rsim.loadingNode fh;
		Rsim.loadContext.instance_eval fh.readlines().join("");
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
		Rsim.loadingNode fh;
		Rsim.loadContext.instance_eval fh.readlines().join("");
		fh.close;
		info("file #{File.absolute_path(fname)} processed",1) if visible;
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
				Rsim.loadingNode fh;
				Rsim.loadContext.instance_eval fh.readlines().join("");
				fh.close;
				info("file #{File.absolute_path(full)} processed",1) if visible;
				loaded=true;break;
			end
		end
		Rsim.exception(NodeE,:reason=>"file not exists in search path(#{fname})") if not loaded;
	end
end
