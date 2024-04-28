# global rhload can be called by user nodes directly or by tool self.
# first use current caller file place + f to search file.
# if not found, then treated as an absolute path.
# from is where this method is called, by default is :node, which means it's directly
# called by user nodes like:
# node.rh: rhload 'f'
# else if it's been called by tool self(:internal), then shall use 
def rhload(f,from=:node)
	if from==:node
		# if is from node, then first to load according to the node path.
		parent = caller(1)[0];
		f=f+'.rh' unless f=~/\./;
		Rsim.info("getting parent path for rhload(#{parent})",9);
		load File.join(parent,f) if File.exists?(File.join(parent,f));
	end
	Rsim.info("getting file direct path(#{f})",9);
	load f;return if File.exists?(f);
	#TODO, raise NodeException.new("file not exists: #{f}");
	Rsim.info("<Exception here> file not exists: #{f}",0);
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
			entry = File.join(stem,entry);
			Rsim.info("loading entry node: #{entry}",9);
			rhload(entry,:internal);
		end
	end

end

