"""
# Object description:
BusInterface, connection information of a specific component
"""
require 'ipxact/IpxData.rb'
class BusInterface <IpxData ##{{{
	# [:object] -> BusDefinition object after elaborate
	# [:id] -> BusDefinition id description
	attr :__abs__;

	attr :__pname__; # parent name, like: a.b.c

	# hash pairs of: <target hierarchy named port/bus> => <target object>
	attr_accessor :consumers;
	## initialize(id), description
	def initialize(id,ref); ##{{{
		#puts "#{__FILE__}:start initialize(id) ..."
		super(:id=>id);
		@__abs__=ref.to_s;
		@__pname__=nil;
		@consumers = {};
	end ##}}}
	## connect(to,block), used for bus connection
	# tn: target object name, for bus it's BusInterface object
	# block: contains port mapping information.
	def connect(tn,block); ##{{{
		@consumers[tn]=block;
	end ##}}}
	## hierarchy, set hierarchy
	def hierarchy(p); ##{{{
		#puts "#{__FILE__}:start hierarchy ..."
		@__pname__=p;
	end ##}}}
	## fullname, return full hierarchical name
	def fullname; ##{{{
		#puts "#{__FILE__}:start fullname ..."
		return %Q|#{@__pname__}.#{id}|;
	end ##}}}
	## elaborate, called by hierarchical evaluating
	def elaborate; ##{{{
		id =@__abs__;
		@__abs__=DataBase.find(id,:busDefinition);
		#Rsim.exception(NodeE,:reason=>"cannot find busDefinition #{id}") unless o;
	end ##}}}
end ##}}}