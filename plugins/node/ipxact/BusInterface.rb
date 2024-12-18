"""
# Object description:
BusInterface, connection information of a specific component
"""
require 'ipxact/IpxData.rb'
class BusInterface <IpxData ##{{{
	# [:object] -> BusDefinition object after elaborate
	# [:id] -> BusDefinition id description
	attr :busDefinition;

	attr :__pname__; # parent name, like: a.b.c

	# hash pairs of: <target hierarchy named port/bus> => <target object>
	attr_accessor :consumers;
	## initialize(id), description
	def initialize(id,ref); ##{{{
		#puts "#{__FILE__}:start initialize(id) ..."
		super(:id=>id);
		@busDefinition={:id=>ref,:object=>nil};
		@__pname__=nil;
		@consumers = {};
	end ##}}}


	## connect(tar), used for bus connection
	# to: target object, for bus it's BusInterface object
	def connect(to); ##{{{
		#puts "#{__FILE__}:start connect(tar) ..."
		@consumers[to.fullname]=to;
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
end ##}}}