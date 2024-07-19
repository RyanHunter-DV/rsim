def rhload(f,from=:node)
	MetaData.rhload(f,from);
end

require 'lib/nls/NodeLoader.rb'
# The module to store database of IP-XACT concept data.
module MetaData
	@nls=nil;
	@registered={
		:Component=>{},
		:GeneratorChain=>{},
		:Design=>{},
		:DesignConfiguration=>{}
	};

	## fileExists(f), description
	def self.fileExists(f); ##{{{
		message='exists?'.to_sym;
		message='exist?'.to_sym if $OS==:Windows;
		return File.send(message,f);
	end ##}}}

	# global rhload can be called by user nodes directly or by tool self.
	# first use current caller file place + f to search file.
	# if not found, then treated as an absolute path.
	# from is where this method is called, by default is :node, which means it's directly
	# called by user nodes like:
	# node.rh: rhload 'f'
	# else if it's been called by tool self(:internal), then shall use 
	## self.rhload, the read rhload
	def self.rhload(f,from=:node); ##{{{
		Rsim.info("calling rhload",9);
		if from==:node
			# if is from node, then first to load according to the node path.
			parent = File.dirname(caller(1)[0].split(/:/)[0]);
			f=f+'.rh' unless f=~/\./;
			full=File.join(parent,f);
			Rsim.info("getting parent path for rhload(#{parent})",9);
			if self.fileExists(full)
				full=File.absolute_path(full);
				load full;
				Rsim.info("file loaded (#{full})",5);
				return;
			end
		end
		Rsim.info("getting file direct path(#{f})",9);
		if self.fileExists(f)
			Rsim.info("direct load by given path",9);
			load f;
			Rsim.info("file loaded (#{f})",5);
			return;
		end
		paths=['./'];paths.append(*$LOAD_PATH);
		paths.each do |p|
			full=File.join(p,f);
			if self.fileExists(full)
				load full;
				Rsim.info("file loaded (#{full})",5);
				return;
			end
		end
		raise NodeE.new("file not exists: #{f}");
	end ##}}}

	## self.loading(entries), load the user nodes.
	def self.loading(entries); ##{{{
		@nls = NodeLoader.new(); ## initNLS
		@nls.loading(entries);
	end ##}}}

	## self.findObjectInPool(id,pool), description
	def self.findObjectInPool(id,pool); ##{{{
		return pool[id] if pool.has_key?(id);
		return nil;
	end ##}}}

	## self.find(id,type), to find registered IP-XACT components by given type
	# if not found, then return nil
	def self.find(id,type); ##{{{
		id=id.to_s;type=type.to_sym;
		found = self.findObjectInPool(id,@registered[type]);
		return found;
	end ##}}}

	## self.register(o,type), description
	def self.register(o,type); ##{{{
		id=o.id;type=type.to_sym;
		Rsim.info("register object(#{o}) with id(#{id}) into #{type}",9);
		@registered[type][id]=o;
	end ##}}}
end