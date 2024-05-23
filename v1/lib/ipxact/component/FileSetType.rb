require 'lib/ipxact/IpXactData.rb'
class FileSetType < IpXactData

	attr_accessor :root;
	attr :files;

	def initialize(n,loc)
		setupNameId(n,:nameGroup);
		Rsim.info("given fileSet block location(#{loc[0]},#{loc[1]})",9);
		@root=File.dirname(loc[0]);
		Rsim.info("root of fileSet(#{id}):(#{@root})",9)
		@files={:inc=>[],:src=>{:incdir=>[],:source=>[]}};
	end

	def inc(*fs)
		return @files[:inc] if fs.empty?;
		@files[:inc].append(*fs);
	end
	def src(*fs)
		return @files[:src] if fs.empty?;
		fs.each do |fs|
			@files[:src][:source]<< fs;
		end
	end
end
