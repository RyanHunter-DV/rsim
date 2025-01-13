"""
# Object description:
FileSet, sub object of a component
"""
class FileSet < IpxData

	#[:verilog]=[{:file=>...,:filelist=>...,...},{xxx}]
	attr :sources;
	attr :includes; # inc dir for certain specified language files.
	attr :root;
	attr :location; # location of the caller node.

	attr :container; # the container object of this fileset
	## initialize(id), description
	def initialize(id,from); ##{{{
		super(:id=>id,:ipxact=>:fileSet);
		@sources={};@includes={};
		#@root=File.dirname(File.absolute_path(__FILE__)); # default root
		@root=nil;
		@location=nil;
		@container=from;
	end ##}}}
	## container(c), set container
	def container(c) ##{{{
		@container=c;
	end ##}}}

	# support commands
	## root(r), set root dir to search for source and include files
	# root shall be based on current container node.rh
	def root(r); ##{{{
		#d= eval %Q|"#{r}"|;
		d=File.join(@container.root,r);
		@root=File.absolute_path(d);
		Rsim.info("getting root: #{@root}",9);
	end ##}}}
	## verilog(*fs), specify verilog language based source files
	def verilog(*fs,**opts); ##{{{
		#puts "#{__FILE__}:start verilog(*fs) ..."
		Rsim.info("getting fs(#{fs}),opts(#{opts})",9);
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
	## vs(inlist=false,*fs=[]), specify custom languaged files
	def vs(*fs,**opts); ##{{{
		opts[:filelist]=false unless opts.has_key?(:filelist);
		opts[:language]=:text unless opts.has_key?(:language);
		lan=opts[:language].to_sym;
		@sources[lan]=[] unless @sources.has_key?(lan);
		@includes[lan]=[] unless @includes.has_key?(lan);

		_setfiles(*fs,**opts);
		@location=caller(1)[0] unless @location;
	end ##}}}
	## print, print data formats

	## elaborate, 
	# the elaborate step for fileset will do:
	# - if no root, then need to add default root
	# - change the sources,includes into absolute path
	# - unique the filelist
	def elaborate; ##{{{
		@root=@container.root unless @root;
		_checkSourceFiles
	end ##}}}

	## source, return all available source files
	def source ##{{{
		r=[];
		@sources.each_pair do |t,ss|
			ss.each do |sf|
				r<<sf[:file];
			end
		end
		return r;
	end ##}}}

private

	## _checkSourceFiles, checking the giving source file existance and change to absolute_path
	def _checkSourceFiles ##{{{
		@sources.each_pair do |t,ss|
			ss.each do |sf|
				fn=sf[:file];
				if Rsim.os.fileExists?(fn,@root)
					sf[:file]=File.join(@root,sf[:file]);
					Rsim.info("get sf: #{sf[:file]}");
				else
					Rsim.exception(NodeE,:reason=>"file(#{fn}) not exists in root(#{@root})");
				end
			end
		end
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
		incs=filterIncludes(*fs);
		lan=opts[:language];
		_inlist=opts[:filelist];
		fs.each do |f|
			sf={:file=>f,:fielist=>_inlist};
			@sources[lan] << sf;
		end
		incs.each do |f|
			sf={:file=>f,:filelist=>_inlist}
			@includes[lan] << sf;
		end
		
	end ##}}}

	
end
