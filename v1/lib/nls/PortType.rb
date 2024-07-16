"""
# Object description:
PortType, object for the port type in IP-XACT, for all ports also the ports in an interface
Typical usage of the PortType:
*declare a port in component*:
```ruby
component do
	port :wire,'name',xxx'
end
```
"""
class PortType ##{{{

	## fields ##
	# attributes, stores following attribute keys into different groups
	# this attributes is of Hash type whose key is the group name in symbol mode, like: @attributes[:system/:master/:slave/:default]
	# the :default group is used for declaring single port.
	# each group attribute is also a hash type that stores following supported options: :direction, :width ...
	# - direction, the port direction, can be :in/:out/:inout/:phantom,
	# phantom here is of internal wire type, others are input, output, inout directions
	# - width-> [msb,lsb], the wired vector port, specified a vector with [msb,lsb] format, for width of 1, can declare like [0,0]
	# - precense-> true/false, indicates if port exists in current group mode.
	#
	# name, the port name, which will be directly generated in module, currently only support one name for ports.
	#
	# type, port type, used to distinguish the IP-XACT port type, 
	# - :wire indicates a wired port which will have vector field,
	# - :trans are not supported yet
	#
	#

	## apis ##
	## initialize(name), description
	def initialize(name); ##{{{
		puts "#{__FILE__}:(initialize(name)) is not ready yet."
		#TODO
	end ##}}}
	## clock, specify the port qualifier as clock
	def clock; ##{{{
		puts "#{__FILE__}:(clock) is not ready yet."
		#TODO
	end ##}}}
	## data, specify the port qualifier as data
	def data; ##{{{
		puts "#{__FILE__}:(data) is not ready yet."
		#TODO
	end ##}}}
	## address, specify port qualifier as address
	def address; ##{{{
		puts "#{__FILE__}:(address) is not ready yet."
		#TODO
	end ##}}}
	## onSystem(**opts), to set option => value pairs while the port is in system group
	def onSystem(**opts); ##{{{
		# 1.raise NodeException if opts' key not recognized
		# 2.set supported opts keys in to specified attribute groups
	end ##}}}
	## onMaster(**opts), set option=>value pairs for master group
	def onMaster(**opts); ##{{{
		puts "#{__FILE__}:(onMaster(**opts)) is not ready yet."
		#TODO
	end ##}}}
	## onSlave(**opts), set option=>value pairs for slave group
	def onSlave(**opts); ##{{{
		puts "#{__FILE__}:(onSlave(**opts)) is not ready yet."
		#TODO
	end ##}}}
	## onDefault(**opts), for default group attributes, used by single port declaration
	def onDefault(**opts); ##{{{
		puts "#{__FILE__}:(onDefault(**opts)) is not ready yet."
		#TODO
	end ##}}}
	## parent(p), set the parent object of this port
	def parent(p); ##{{{
		puts "#{__FILE__}:(parent(p)) is not ready yet."
		#TODO
	end ##}}}
end ##}}}