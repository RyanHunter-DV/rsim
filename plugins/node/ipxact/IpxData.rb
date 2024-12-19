"""
# Object description:
IpxData, base object of IP-XACT data
"""
class IpxData ##{{{

	attr_accessor :id;
	attr_accessor :elaborated;

	attr :__evals__;
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
	end ##}}}

	## add(block), add evaluate blocks into __evals__
	def add(block); ##{{{
		#puts "#{__FILE__}:start add(block) ..."
		@__evals__ << {:loc=>block.source_location,:proc=>block};
	end ##}}}

	## elaborate, description
	def elaborate; ##{{{
		Rsim.report.error("elaborate not available for #{@id}");
	end ##}}}
end ##}}}