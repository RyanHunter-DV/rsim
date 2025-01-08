class Ipxact

	#@pool={:component=>{id=>object,...},...}
	attr :pool;

	## initialize(ui), init ipxact system
	# 1.attr init
	# 2.load required chain definitions
	def initialize(ui) ##{{{
		@pool={};
		_chainLoad(ui.<requiredChainNamesInArray>,ui.<requiredChainDefinePath>); #TODO
	end ##}}}

	## register(), description
	def register(o,t); ##{{{
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
	def find(n,t,report=true); ##{{{
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


	## elaborate, description
	def elaborate; ##{{{
		# to elaborate the loaded nodes
		#@pool.each_pair do |t,os|
		#	next if t==:generatorChain;
		#	os.each_value do |o|
		#		o.elaborate;
		#	end
		#end
		etype(:component) if @pool.has_key?(:component);
		etype(:design) if @pool.has_key?(:design);
	end ##}}}
	## etype(t), elaborate according to different ipx type
	def etype(t); ##{{{
		s=@pool[t];
		s.each_value do |o|
			Rsim.info("elaborating ipx #{t}:#{o.id}");
			o.elaborate;
		end
	end ##}}}
	## finalize, description
	def finalize; ##{{{
		@pool.each_pair do |t,os|
			next if t==:generatorChain;
			os.each_value do |o|
				Rsim.info("finalizing ipx #{t}:#{o.id}");
				o.finalize;
			end
		end
	end ##}}}
private
	## _chainLoad(ns), load required chains according to given chain execute name
	def _chainLoad(ns) ##{{{
		#1.setup chain definition path
		#2.setup chain name, execute name + 'flow'
		#3.find file in giving path
		#4.call require
		ns.each do |ename|
			cname=ename+'flow';
		end
	end ##}}}
end
