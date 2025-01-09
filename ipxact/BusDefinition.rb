"""
# Object description:
BusDefinition, support IP-XACT concepts:
vlnv,
maxMasters
maxSlaves
"""
require 'ipxact/IpxData.rb'
class BusDefinition < IpxData
	attr :__max__;
	## initialize(vlnv), description
	def initialize(vlnv); ##{{{
		super(:id=>vlnv);
		@__max__={:master=>0,:slave=>0};
	end ##}}}
	## maxMasters(n), set max master
	def maxMasters(n); ##{{{
		@__max__[:master]=n;
	end ##}}}
	## maxSlaves(n), set max slave number
	def maxSlaves(n); ##{{{
		@__max__[:slave]=n;
	end ##}}}
end
