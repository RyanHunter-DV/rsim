class Ipxact

	#@pool={:component=>{id=>object,...},...}
	attr :pool;

	attr :chains;
	attr :searchPath;

	attr_accessor :config;

	## initialize(ui), init ipxact system
	# 1.attr init
	# 2.load required chain definitions
	def initialize(ui) ##{{{
		@pool={};
		#loadChain(ui.chainNames,ui.chainSearchPath);
		@chains=ui.chainNames;
		@searchPath = ui.chainSearchPath;
	end ##}}}
	## loadChain(ns), load required chains according to given chain execute name
	#TODO
	def loadChain() ##{{{
		names=@chains;
		incs=@searchPath;
		files=[];
		#1.setup chain definition path
		#2.setup chain name, execute name + 'flow'
		names.each do |en|
			cn=en+'flow.rb';
			f=Rsim.os.search(:file,cn,incs);
			#3.find file in giving path
			if f
				files << f;
			else
				Rsim.exception(
					:UIE,
					:reason=>"generatorChain(#{en}) not defined in search path #{incs}"
				);
			end
		end
		#4.call require
		files.each do |file|
			Rsim.info("loading chain #{file}");
			require file;
		end
	end ##}}}
	## select(exen,gn,**opts), select generator according to chain's execute name and generator name
	def select(exen,gn,**opts) ##{{{
		cn="#{exen}flow";
		c=find(cn,:generatorChain);
		c.select(gn,opts);
	end ##}}}

	## register(), description
	def register(o,t); ##{{{
		Rsim.info("register #{o.id} of #{t} to ipxact database")
		t=t.to_sym;
		
		@pool[t]={} unless @pool.has_key?(t);
		@pool[t][o.id]=o;
		if t==:generatorChain
			message = o.exename.to_sym;
			Rsim.info("defining single method(#{message}) of flow(#{o.id})",9);
			define_singleton_method message do |opts={}| ##{{{
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
		etype(:component) if @pool.has_key?(:component);
		etype(:design) if @pool.has_key?(:design);
		etype(:config) if @pool.has_key?(:config);
		etype(:suite) if @pool.has_key?(:suite);
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
	def finalize(cn); ##{{{
		o=@pool[:config][cn];
		Rsim.exception(UIE,:reason=>"config #{cn} not declared") unless o;
		Rsim.info("finalizing config: #{o.id}");
		@config=o;
		o.finalize;

		# all test suites required to be finalized
		os=@pool[:suite];
		os.each_value do |o|
			Rsim.info("finalizing ipx suite:#{o.id}");
			o.finalize;
		end
		#@pool.each_pair do |t,os|
		#	next if t==:generatorChain;
		#end
	end ##}}}
private
end
