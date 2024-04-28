require 'lib/ipxact/IpXactData.rb'
require 'lib/ipxact/component/FileSetType.rb'
class ViewType < IpXactData

	attr :hierarchyRef;

	attr_accessor :language;
	attr_accessor :modelName;
	attr_accessor :fileSet;

	def initialize(vn)
		setupNameId(vn,:nameGroup);
		@hierarchyRef=nil;
		@modelName=''; # not necessary for SV package components.
		@fileSet = nil;
	end

	def isHierarchical
		return true if @hierarchyRef;
		return false;
	end

	def finalize
		if @hierarchyRef
			d=MetaData.find(@hierarchyRef,:design)
			raise NodeException.new("referenced design not found") unless d;
			@hierarchyRef=d;
		end
	end

	# user command to declare an hierarchical view for a design ref
	def hierarchyRef(ref)
		# command will just set the reference name, and in finalize phase, which will
		# search the referenced design object.
		@hierarchyRef=ref.to_s;
	end
	def modelName(n)
		@modelName=n.to_s;
	end
	def language(l)
		@language=l.to_sym;
	end
	def fileSet(n,&block) ##{{{
		raise NodeException.new("at least one file info must specified by fileSet") unless block_given?;
		n=n.to_s;
		fs=FileSetType.new(n,block.source_location);
		fs.instance_eval block;
		@fileSet=fs;
	end ##}}}
end
