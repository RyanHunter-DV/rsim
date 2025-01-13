class MetaData
	"""
	class to record IPXACT info as database, and can be translated to different format.
	"""

	attr :type;
	attr :vlnv;
	attr :__fields__;
	attr :filename;

	## initialize(t,id), description
	def initialize(t,id) ##{{{
		@type=t.to_sym;
		@vlnv=id;
		@__fields__=[:type,:vlnv];
		@filename='metadata';
	end ##}}}

	## record(k,v,p=:main), record a new data key -> value pair
	# p is the parent key name,if not provided, then default is as parent key
	def record(k,v,p=:main) ##{{{
		#TODO
		if p==:main
			self.instance_variable_set("@#{k}",v);
			@__fields__<<k.to_s;
		else
			c=self.instance_variable_get("@#{p}");
			Rsim.exception(NodeE,:reason=>"parent key(#{p}) not set yet") unless c;
			c[k.to_sym]=v;
		end
	end ##}}}
	## add(k,v), call add will treat the key is an array and will get the variable 
	# and add to new value.
	def add(k,v) ##{{{
		unless self.instance_variable_defined?("@#{k}")
			self.instance_variable_set("@#{k}",[]);
			@__fields__<<k.to_s;
		end
		c=self.instance_variable_get("@#{k}");
		c << v;
	end ##}}}
	## dataString(t=:ruby), return hash based data format for ruby
	def dataString(t=:ruby) ##{{{
		ds={};
		@__fields__.each do |fn|
			fv=self.instance_variable_get("@#{fn}");
			ds[fn]=fv;
		end
		return ds;
	end ##}}}
	## write, write recordd data into metadata file in the given path
	def write(path) ##{{{
		ds=self.dataString;
		Rsim.os.mkdir(path,:recursive=>true) unless Rsim.os.exists?(:dir,path);
		fh=File.open(File.join(path,@filename),'w');
		fh.write(ds);
		fh.close;
	end ##}}}
end
