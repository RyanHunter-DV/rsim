"""
# Object description:
RegisterData, ip-xact object of register
"""
require 'lib/nls/RegisterFieldData'
class RegisterData ##{{{

	attr_accessor :fields;

	attr :size; # size of bits
	attr :offset;
	attr :name;

	## initialize(name,offset,bits), description
	def initialize(name,offset,bits); ##{{{
		puts "#{__FILE__}:(initialize(name,offset,bits)) is not ready yet."
		@name=name;
		@offset=offset;
		@size=bits;
	end ##}}}
	
	## field(name,lsb,bits,access,reset), declare a new field with given field attributes
	# 1.name, field name
	# 2.lsb, the LSB position index
	# 3.bits, size of bits of this field
	# 4.access, the access type, string type
	# 5,reset, reset value, string type
	def field(name,lsb,bits,access,reset); ##{{{
		f=RegisterFieldData.new(name,lsb,bits,access,reset);
	end ##}}}
end ##}}}