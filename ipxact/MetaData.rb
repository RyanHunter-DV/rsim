class MetaData
	"""
	class to record IPXACT info as database, and can be translated to different format.
	"""

	attr :type;
	attr :id;

	## initialize(t,id), description
	def initialize(t,id) ##{{{
		@type=t.to_sym;
		@id=id;
	end ##}}}

	## record(k,v,p=:main), record a new data key -> value pair
	# p is the parent key name,if not provided, then default is as parent key
	def record(k,v,p=:main) ##{{{
		#TODO
		if p==:main
			self.instance_variable_set("@#{k}",v);
		else
			c=self.instance_variable_get("@#{p}");
			Rsim.exception(NodeE,:reason=>"parent key(#{p}) not set yet") unless c;
			c[k.to_sym]=v;
		end
	end ##}}}
end
