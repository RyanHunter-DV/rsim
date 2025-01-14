class TestTemplate < IpxData
	# before finalize, it's config name, after finalize, it's config object
	attr :config; 
	attr :flow;
	attr :options;

	def initialize(n,t=:testTemplate)
		super(:id=>n.to_s,:ipxact=>t)
		@options=[];
	end

	#### support commands {
	## config(n=nil), specify the config name
	def config(n=nil) ##{{{
		return @config unless n;
		@config=n.to_s;
	end ##}}}
	## flow(n), specify the flow execute name
	def flow(n=nil) ##{{{
		return @flow unless n;
		@flow=n.to_sym;
	end ##}}}
	## args(*as), args for running the flow, can support multiple args
	def args(as=[]) ##{{{
		return @options if as.empty?;
		@options.append(*as);
	end ##}}}
	#### }

end
