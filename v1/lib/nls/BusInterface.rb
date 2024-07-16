"""
# Object description:
BusInterface, ruby class to describe the busDefinition and abstractionDefinition in IP-XACT
"""
require 'lib/nls/BusAbstraction'
class BusInterface ##{{{

	attr :abstractions;
	# maxClients[type] is specific typed client's max supported number
	attr :maxClients;

	## initialize(vlnv), description
	def initialize(vlnv); ##{{{
		puts "#{__FILE__}:(initialize(vlnv)) is not ready yet."
		# setup name id: vlnv.

		# init fields
		@abstractions={};
		@maxClients={};
	end ##}}}

	## apis ##
	## abstraction(vlnv,&block), node command to declare a new abstraction of this bus type
	# one BusInterface can have multiple abstractions, each describes a set of low level port behaviors.
	def abstraction(vlnv,&block); ##{{{
		#TODO
		# 1.create a new BusAbstraction object.
		a=BusAbstraction.new(vlnv); #TODO, require BusAbstraction object.
		# 2.eval the block
		a.instance_eval &block;
		# 3.register
		@abstractions[vlnv] = a;
	end ##}}}

	## maxClients(t,n), define max clients for specified type, type will be:
	# :master, as master client
	# :slave, as slave client
	def maxClients(t,n); ##{{{
		@maxClients[t.to_sym]=n;
	end ##}}}
end ##}}}

## bus(vlnv,&block), global command to declare a busDefinition, which will have multiple abstractions
def bus(vlnv,&block); ##{{{
	#TODO.
	#1.create new object of bus interface
	o=BusInterface.new(vlnv);
	#2.add node block
	o.addUserNode(block);
	#3.register to MetaData with type bus
end ##}}}