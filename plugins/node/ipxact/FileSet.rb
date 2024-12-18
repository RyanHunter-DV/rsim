"""
# Object description:
FileSet, sub object of a component
"""
require 'ipxact/IpxData.rb'
class FileSet < IpxData ##{{{

	attr :sources;
	attr :includes; # inc dir for certain specified language files.
	attr :root;
	attr :location; # location of the caller node.

	## initialize(id), description
	def initialize(id); ##{{{
		#puts "#{__FILE__}:start initialize(id) ..."
		super(:id=>id);
		@sources={};@includes={};
		#@root=File.dirname(File.absolute_path(__FILE__)); # default root
		@root=nil;
		@location=nil;
	end ##}}}

	# support commands
	## root(r), set root dir to search for source and include files
	def root(r); ##{{{
		#puts "#{__FILE__}:start root(r) ..."
		d= eval %Q|"#{r}"|;
		@root=File.absolute_path(d);
		#TODO
	end ##}}}
	## verilog(*fs), specify verilog language based source files
	def verilog(*fs,**opts); ##{{{
		#puts "#{__FILE__}:start verilog(*fs) ..."
		opts[:filelist]=true unless opts.has_key?(:filelist);
		@sources[:verilog]=[] unless @sources.has_key?(:verilog);
		@includes[:verilog]=[] unless @includes.has_key?(:verilog);
		# TODO,
		# when given fs has dirs, then those dirs will be automatically added into includes[:verilog] list.
		# if inlist is false, then the given files and includes will be set the :filelist=>false.
		opts[:language]=:verilog;
		_setfiles(*fs,**opts);
		@location=caller(1)[0] unless @location;
	end ##}}}
	## sv(inlist=true,*fs=[]), 
	# specify SV language based source files
	def sv(*fs,**opts); ##{{{
		#puts "#{__FILE__}:start sv(inlist=true,*fs=[]) ..."
		opts[:filelist]=true unless opts.has_key?(:filelist);
		@sources[:sv]=[] unless @sources.has_key?(:sv);
		@includes[:sv]=[] unless @includes.has_key?(:sv);

		opts[:language]=:sv;
		_setfiles(*fs,**opts);
		@location=caller(1)[0] unless @location;
	end ##}}}
	## custom(inlist=false,*fs=[]), specify custom languaged files
	def custom(*fs,**opts); ##{{{
		#puts "#{__FILE__}:start custom(inlist=false,*fs=[]) ..."
		opts[:filelist]=false unless opts.has_key?(:filelist);
		opts[:language]=:text unless opts.has_key?(:language);
		lan=opts[:language].to_sym;
		@sources[lan]=[] unless @sources.has_key?(lan);
		@includes[lan]=[] unless @includes.has_key?(lan);

		_setfiles(*fs,**opts);
		@location=caller(1)[0] unless @location;
	end ##}}}
	## print, print data formats
	def display; ##{{{
		puts "type: FileSet";
		puts "- id: #{id}";
		puts "- root: #{@root}";
		puts "- sources:"
		@sources.each_pair do |l,ss|
			puts "-- language: #{l}";
			ss.each do |s|
				puts "-- file: #{s}"
			end
		end
		puts "- includes:"
		@includes.each_pair do |l,ss|
			puts "-- language: #{l}";
			ss.each do |s|
				puts "-- file: #{s}"
			end
		end
	end ##}}}

	## elaborate, 
	# the elaborate step for fileset will do:
	# - if no root, then need to add default root
	# - change the sources,includes into absolute path
	# - unique the filelist
	def elaborate; ##{{{
		#puts "#{__FILE__}:start elaborate ..."
		#TODO
		
	end ##}}}


private
	## setDefaultRoot(c), according to the caller information, set the default root
	# this will be called only after nodes loaded, in elaborate phase.
	def setDefaultRoot(c); ##{{{
		#puts "#{__FILE__}:start setDefaultRoot(c) ..."
		#TODO
	end ##}}}

	## filterIncludes(*fs), according to given
	# files, filter if those files has included paths,
	# filtered paths shall be done with unique.
	def filterIncludes(*fs); ##{{{
		#puts "#{__FILE__}:start filterIncludes(*fs) ..."
		incs=[];
		fs.each do |f|
			incs.append(_filterPathRecursivly(f));
		end
		return incs.uniq;
	end ##}}}
	## _filterPathRecursivly(f), filter all available paths from given file name
	# f:
	# name.xxx
	# p/name.xx
	# p/a//name.xxx
	# /p//name.xx
	def _filterPathRecursivly(f); ##{{{
		#puts "#{__FILE__}:start _filterPathRecursivly(f) ..."
		ps=[];
		acc='';
		splitted=f.split('/');
		splitted.length.times do |l|
			next if (splitted[l]=='' or splitted[l]==nil);
			break if ((l+1) == splitted.length);
			acc = acc+splitted[l];
			ps << acc;
			acc+='/';
		end
		return ps;
	end ##}}}
	## _setfiles(*fs,**opts), description
	def _setfiles(*fs,**opts); ##{{{
		#puts "#{__FILE__}:start _setfiles(*fs,**opts) ..."
		incs=filterIncludes(*fs);
		lan=opts[:language];
		_inlist=opts[:filelist];
		fs.each do |f|
			sf={:file=>f,:fielist=>_inlist};
			@sources[lan]<<sf;
		end
		incs.each do |f|
			sf={:file=>f,:filelist=>_inlist}
			@includes[lan]<<sf;
		end
		
	end ##}}}

	
end ##}}}