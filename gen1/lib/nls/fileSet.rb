"""
# Object description:
FileSet, object to store DE file information
"""
require 'lib/nls/IpXactData.rb'
require 'lib/exceptions.rb'
require 'common/Shell.rb'
class FileSet < IpXactData ##{{{
	# source file names
	# format is: [{:name=>'path/name.*',:filelist=>true/false},{...}]
	attr :source; 
	attr :incdir; # search paths

	attr_accessor :root; # root path, by default is the node location.

	## initialize(id), description
	def initialize(id,loc); ##{{{
		super(id);
		@source=[]; @incdir=[];
		Rsim.info("loc(#{loc})",9);
		@root= File.absolute_path(File.dirname(loc[0]));
	end ##}}}

	## sources(t=:full), according to the given type, return raw source or
	# files only
	# t=:full, return the source list containing full information.
	# t=:file, return the files only
	def sources(t=:full); ##{{{
		return @source if t==:full;
		rtns=[];
		@source.each do |item|
			Rsim.info("getting sources, file info:(#{item})")
			rtns << item[:name];
		end
		return rtns;
	end ##}}}

	## realpath(f), 
	# if current f exists, then use f, else use @root/f
	def realpath(f); ##{{{
		return File.absolute_path(f) if File.exist?(f);
		full = File.absolute_path(File.join(@root,f)) ;
		return full if File.exist?(full);
		raise NodeE.new("cannot find file(#{f}) in search path");
		return f;
	end ##}}}

	## addSearchPath(p), description
	def addSearchPath(p); ##{{{
		return if @incdir.include?(p);
		@incdir<<p;
	end ##}}}

	## source(*f), specify source files, all files added by this
	# command will be added to filelist.
	def source(*fs); ##{{{
		fs.each do |f|
			Rsim.info("inserting source file,f: #{f}",9)
			full = realpath(f);
			Rsim.info("inserting source file,full: #{full}",9)
			@source << {:filelist=>true,:name=>full};
			addSearchPath(File.dirname(full));
		end
	end ##}}}

	## include(*fs), add files that are not in filelist,
	# but may will be used by buildflow or something else.
	def includes(*fs); ##{{{
		fs.each do |f|
			full = realpath(f);
			@source << {:filelist=>false,:name=>full};
			addSearchPath(File.dirname(full));
		end
	end ##}}}

	## appendIntoFilelist(fn), api to append current fileSet's files
	# that are marked shall be into filelist write into given filelist.
	def appendIntoFilelist(fn,simulator); ##{{{
		cnts=[];
		#cnts.append(*@incdir);
		@incdir.each do |dir|
			cnts << simulator.translate('incdir',dir);
		end
		@source.each do |src|
			cnts << src[:name] if src[:filelist]==true;
		end
		cnts.uniq!;
		Shell.injectLines(fn,cnts);
	end ##}}}
end ##}}}