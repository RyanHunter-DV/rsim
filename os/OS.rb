"""
# Object description:
OS, description
"""
class OS ##{{{
	
	# :Linux, :Mac, :Windows
	attr :__sep__; # file separator
	attr_accessor :type;
	## initialize, description
	def initialize(t=:Linux); ##{{{
		#puts "#{__FILE__}:start initialize ..."
		@type=t.to_sym;
		@__sep__ = {:Linux=>'/',:Mac=>'/',:Windows=>'\\'};
	end ##}}}
	## fileExists?(fn,path='.'), description
	def fileExists?(fn,path=nil); ##{{{
		#puts "#{__FILE__}:start fileExists?(#{fn},#{path}) ..."
		fn=File.join(path,fn) unless path==nil;
		fn= _convertPath(fn);
		return true if File.exist?(fn);
		return false;
	end ##}}}
	def readfile(fn); ##{{{
		#puts "#{__FILE__}:start readfile(fn) ..."
		fh=File.open(fn,'r');
		contents = fh.readlines();
		fh.close;
		return contents;
	end ##}}}
	## translatePathName(org), description
	def translatePathName(org); ##{{{
		#puts "#{__FILE__}:start translatePathName(org) ..."
		return _convertPath(org);
	end ##}}}
	## mkdir(p,**opts), 
	# make dir, support options:
	# [:recursive] => true, then to make all dirs from which not exists until to the deepest level.
	def mkdir(p,**opts); ##{{{
		rec = false;
		rec = opts[:recursive] if opts.has_key?(:recursive);
		# 1.check is abs path or relative path by detecting the p[0]
		abs=false;
		abs=true if p[0]=='/';
		# 2.if rec, call dirname until gets '/', and append all paths into array
		# 3.reverse the array
		paths=_getRecursivePath(p,abs) if rec;
		# 4.checking existance and making dir
		paths.each do |path|
			system(%Q|mkdir -p #{path}|) unless fileExists?(path);
		end
	end ##}}}
	## rm(fn), description
	#[:recursive], remove with '-r' option or not
	def rm(fn,path=nil,**opts); ##{{{
		cmd="rm -";
		cmd+= 'r' if opts.has_key?(:recursive) and opts[:recursive];
		cmd+= 'f'
		fn=File.join(path,fn) if path;
		cmd+= " #{fn}";
		system(cmd);
	end ##}}}
	## link(src,tar), link src with target name
	def link(src,tar); ##{{{
		File.unlink(tar) if File.symlink?(tar);
		File.symlink(src,tar);
	end ##}}}

private
	## _convertPath(org), description
	def _convertPath(org); ##{{{
		#puts "#{__FILE__}:start _convertPath(#{org}) ..."
		return org.gsub(/\//,@__sep__[@type]);
	end ##}}}
	## _getRecursivePath(p,abs=false), 
	
	def _getRecursivePath(p,abs=false); ##{{{
		top='.';
		top='/' if abs;
		c=p;
		stack=[];
		while (c!=top)
			stack << c;
			c=File.dirname(c);
		end
		return stack.reverse;
	end ##}}}
end ##}}}