"""
# Object description:
IpxParameter, class to behave the IPX parameter setting, getting operations
used for component, generator and abstractions
"""
class IpxParameter ##{{{
	
	attr_accessor :name;

	attr :value;

	# current parameter data type
	# int or string, if is Symbol, it will be translated string while using
	attr :type; 
	## initialize(name,default), description
	def initialize(n,default); ##{{{
		@name=n.to_sym;
		@value= default;
		@type = default.class;
	end ##}}}

	## set(v), set the parameter with new value
	#TODO
	def set(v); ##{{{
		
	end ##}}}
	## get, get the latest setting value
	#TODO
	def get; ##{{{
		
	end ##}}}
end ##}}}