# global rhload can be called by user nodes directly or by tool self.
# first use current caller file place + f to search file.
# if not found, then treated as an absolute path.
# from is where this method is called, by default is :node, which means it's directly
# called by user nodes like:
# node.rh: rhload 'f'
# else if it's been called by tool self(:internal), then shall use 
def rhload(f,from=:node)
	Rsim.info("calling rhload",9);
	if from==:node
		# if is from node, then first to load according to the node path.
		parent = File.dirname(caller(1)[0].split(/:/)[0]);
		f=f+'.rh' unless f=~/\./;
		full=File.join(parent,f);
		Rsim.info("getting parent path for rhload(#{parent})",9);
		Rsim.info("get full file path(#{full})",9);
		if File.exists?(full)
			load full;
			return;
		end
	end
	Rsim.info("getting file direct path(#{f})",9);
	if f[0]=='/' and File.exists?(f)
		Rsim.info("load by absolute path",9);
		load f;
		return;
	end
	paths=['./'];paths.append(*$LOAD_PATH);
	paths.each do |p|
		full=File.join(p,f);
		if File.exists?(full)
			Rsim.info("get load file(#{full})",9);
			load full;
			return;
		end
	end
	raise NodeException.new("file not exists: #{f}");
	#Rsim.info("<Exception here> file not exists: #{f}",0);
end

class NodeManager
	def initialize(ui)
		# entries are array items like: ['path/file','path/file']
		loading(ui.stem,ui.entries);
	end

	# load all root entries and their includes, and eval
	# the commands to register information in MetaData module scope.
	def loading(stem,entries)
		entries.each do |entry|
			#entry = File.absolute_path(File.join(stem,entry));
			entry = Rsim.join(stem,entry);
			Rsim.info("loading entry node: #{entry}",9);
			rhload(entry,:internal);
		end
	end

end

