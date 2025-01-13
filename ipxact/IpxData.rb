"""
# Object description:
IpxData, base object of IP-XACT data
"""
class IpxData

	attr_accessor :id;
	attr_accessor :elaborated;

	attr :__evals__;
	attr :__type__; # object type
	attr :metadata; # internal metadata object

	## initialize(opts={}), 
	def initialize(opts={}); ##{{{
		#puts "#{__FILE__}:start initialize(opts={}) ..."
		Rsim.report.error("id must given when using IpxData") unless opts.has_key?(:id);
		# for types like component , the id is the vlnv
		# for other types, the id can be name group type, which is always the unique identifier
		# of all IP-XACT data.
		@id = opts[:id].to_s;
		@elaborated=false;
		@__evals__=[];
		@metadata=MetaData.new(opts[:ipxact].to_sym,@id);
	end ##}}}

	## add(block), add evaluate blocks into __evals__
	def add(block); ##{{{
		#puts "#{__FILE__}:start add(block) ..."
		@__evals__ << {:loc=>block.source_location,:proc=>block};
	end ##}}}
	## evalNodes, description
	def evalNodes; ##{{{
		@__evals__.each do |e|
			self.instance_eval &e[:proc]
		end
	end ##}}}
	## elaborate, description
	def elaborate; ##{{{
		Rsim.info("nothing to do with #{@id}",1);
	end ##}}}
	## finalize, description
	def finalize ##{{{
		Rsim.info("nothing to do with #{@id}",1);
	end ##}}}

	## data, return a hash that contains unified ipxact concepts
	def data ##{{{
		
	end ##}}}
end
