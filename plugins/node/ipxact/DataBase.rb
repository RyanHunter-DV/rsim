module DataBase

	@pool={};

	## self.register(), description
	def self.register(o,t); ##{{{
		Rsim.info("register #{o.id} of #{t} to ipxact database")
		t=t.to_sym;
		
		@pool[t]={} unless @pool.has_key?(t);
		@pool[t][o.id]=o;
	end ##}}}

	## find(n,t), description
	def find(n,t); ##{{{
		#puts "#{__FILE__}:start find(n,t) ..."
		n=n.to_s;t=t.to_sym;
		unless @pool.has_key?(t)
			Rsim.exception(NodeE,:reason=>"cannot find #{t}::#{n} in ipxact DataBase");
		end
		unless @pool[t].has_key?(n)
			Rsim.exception(NodeE,:reason=>"cannot find #{t}::#{n} in ipxact DataBase");
		end
		Rsim.info("find #{t}::#{n} in ipxact DataBase",5);
		return @pool[t][n];
	end ##}}}
end