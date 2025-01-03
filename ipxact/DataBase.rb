module DataBase

	#@pool={:component=>{id=>object,...},...}
	@pool={};

	## self.register(), description
	def self.register(o,t); ##{{{
		Rsim.info("register #{o.id} of #{t} to ipxact database")
		t=t.to_sym;
		
		@pool[t]={} unless @pool.has_key?(t);
		@pool[t][o.id]=o;
		if t==:generatorChain
			message = o.id.to_sym;
			define_singleton_method message do |**opts| ##{{{
				Rsim.info("execute flow, opts: #{opts}",5);
				o.execute(**opts);
			end ##}}}
		end
	end ##}}}

	## find(n,t), description
	def self.find(n,t,report=true); ##{{{
		#puts "#{__FILE__}:start find(n,t) ..."
		n=n.to_s;t=t.to_sym;
		unless @pool.has_key?(t)
			Rsim.exception(NodeE,:reason=>"cannot find #{t}::#{n} in ipxact DataBase") if report;
			return nil;
		end
		unless @pool[t].has_key?(n)
			Rsim.exception(NodeE,:reason=>"cannot find #{t}::#{n} in ipxact DataBase") if report;
			return nil;
		end
		Rsim.info("find #{t}::#{n} in ipxact DataBase",5);
		return @pool[t][n];
	end ##}}}


	## self.elaborate, description
	def self.elaborate; ##{{{
		# to elaborate the loaded nodes
		#@pool.each_pair do |t,os|
		#	next if t==:generatorChain;
		#	os.each_value do |o|
		#		o.elaborate;
		#	end
		#end
		self.etype(:component) if @pool.has_key?(:component);
		self.etype(:design) if @pool.has_key?(:design);
	end ##}}}
	## self.etype(t), elaborate according to different ipx type
	def self.etype(t); ##{{{
		s=@pool[t];
		s.each_value do |o|
			Rsim.info("elaborating ipx #{t}:#{o.id}");
			o.elaborate;
		end
	end ##}}}
	## self.finalize, description
	def self.finalize; ##{{{
		@pool.each_pair do |t,os|
			next if t==:generatorChain;
			os.each_value do |o|
				Rsim.info("finalizing ipx #{t}:#{o.id}");
				o.finalize;
			end
		end
	end ##}}}
end