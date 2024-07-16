"""
# Object description:
BusAbstraction, for defining abstraction of a bus interface
# using example:
abstraction 'vlnv' do
	wire 'xxx' do
		clock # data, address, for qualifier
		# direction option supports :in,:out,:inout
		# width option supports [lhs,rhs]
		# presence => true/false
		onSystem :direction => :in, :width => [0,2]
		onMaster # same option with onSystem
		onSlave # same option with onSystem
	end
end
"""
require 'lib/nls/PortType'
class BusAbstraction ##{{{
	
	## apis ##
	## initialize(vlnv), description
	def initialize(vlnv); ##{{{
		puts "#{__FILE__}:(initialize(vlnv)) is not ready yet."
		#TODO
	end ##}}}

	## wire(name,&block), declare a new wired port for this abstraction
	def wire(name,&block); ##{{{
		puts "#{__FILE__}:(wire(name,&block)) is not ready yet."
		#TODO
		#1.create new PortType, with type :wire
		#2.eval bock in PortType, shall support command:
		# clock, data, address
		# onSystem, onMaster, onSlave
	end ##}}}

end ##}}}