"""
# Object description:
FileSet, object to store DE file information
"""
require 'lib/nls/IpXactData.rb'
require 'lib/exceptions.rb'
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
		@root= File.absolute_path(File.dirname(loc));
	end ##}}}

	## realpath(f), 
	# if current f exists, then use f, else use @root/f
	def realpath(f); ##{{{
		puts "#{__FILE__}:(realpath(f)) is not ready yet."
		return File.absolute_path(f) if File.exist?(f);
		full = File.absolute_path(@root,f) ;
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
			full = realpath(f);
			@source << {:filelist=>true,:name=>full};
			addSearchPath(File.dirname(full));
		end
	end ##}}}

	## include(*fs), add files that are not in filelist,
	# but may will be used by buildflow or something else.
	def include(*fs); ##{{{
		fs.each do |f|
			full = realpath(f);
			@source << {:filelist=>false,:name=>full};
			addSearchPath(File.dirname(full));
		end
	end ##}}}
end ##}}}