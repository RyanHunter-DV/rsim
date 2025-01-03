require 'ipxact/IpxData.rb'

"""
# Object description:
Port, the common port base, which are parent class of the
transaction port and wire port
"""
class Port < IpxData ##{{{
	attr :porttype;

	## initialize(name), description
	def initialize(name,t); ##{{{
		#puts "#{__FILE__}:start initialize(name) ..."
		super(:id=>name);
		@porttype=t;
	end ##}}}

	## type(t=nil), get or change the port type
	# :transaction, :wire
	def type(t=nil); ##{{{
		#puts "#{__FILE__}:start type(t=nil) ..."
		return @porttype unless t;
		@porttype=t;
	end ##}}}
end ##}}}