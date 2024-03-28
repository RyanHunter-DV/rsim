"""
# Object description:
Component, 
Represents the IP-XACT component, created by the global component command, which usually been called
in user nodes.
"""
class Component ##{{{
	## initialize, 
	# the constructor
	def initialize; ##{{{
		puts "#{__FILE__}:(initialize) is not ready yet."
		#TODO
	end ##}}}

	## -- Supported commands for user nodes ##{{{
	## generator(name), 
	# specify a generator name.
	# block used to declare extra parameters for the generator.
	def generator(name,&block); ##{{{
		puts "#{__FILE__}:(generator(name)) is not ready yet."
		
	end ##}}}

	## }}}




private

	## -- Internal APIs for object self interactions ##{{{

	## }}}

end ##}}}

## component(vlnv,&block), 
# user nodes to define an IP-XACT component
# format:
# - component 'vendor/library/name/version', do xxx end
def component(vlnv,&block); ##{{{
	puts "#{__FILE__}:(component(vlnv,&block)) is not ready yet."
	#TODO
end ##}}}