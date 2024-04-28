require 'lib/ipxact/IpXactData.rb'
class FileSetType < IpXactData

	attr :root;
	attr :files;

	def initialize(n,loc)
		setupNamId(n,:nameGroup);
		@root=File.dirname(loc);
		@files={:inc=>[],:src=>{:incdir=>[],:source=>[]}};
	end

	def inc(*fs)
		@files[:inc].append(*fs);
	end
	def src(*fs)
		@files[:src][:source].append(*fs);
	end
end
