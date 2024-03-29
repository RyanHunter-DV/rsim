"""
# Object description:
IpXactData, base and common object for IP-XACT
"""
class IpXactData ##{{{
	
	attr_accessor :datatype;
	attr :nodes;
	attr :desc;
	## initialize(t), description
	def initialize(t); ##{{{
		puts "#{__FILE__}:(initialize(t)) is not ready yet."
		@datatype=t.to_sym;
		@nodes=[];
		@desc='';
	end ##}}}

	## addUserNode(b), description
	def addUserNode(b); ##{{{
		puts "#{__FILE__}:(addUserNode(b)) is not ready yet."
		@nodes << b;
	end ##}}}
	## description(d)
	def description(d); ##{{{
		puts "#{__FILE__}:(description(d)) is not ready yet."
		@desc = d;
	end ##}}}
end ##}}}