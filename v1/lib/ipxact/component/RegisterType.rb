require 'lib/ipxact/IpxactData.rb'

"""
# Object description:
RegisterType, class to place the information of the component's registers
User node description:
component ... do
	memoryMap ... do
		register 'name','' do
			field 'xxx', :bitOffSet=>'xx',:bitWidth=>'xx',:access=>'xxx',:reset=>'xx'
			field 'xxx', :bitOffSet=>'xx',:bitWidth=>'xx',:access=>'xxx',:reset=>'xx'
			...
		end
		register 'name',:size=>'xx',:offset=>'xxx',:access=>'xxx' do
			field 'xxx', :bitOffSet=>'xx',:bitWidth=>'xx',:access=>'xxx',:reset=>'xx'
			...
		end
	end
end
"""
class RegisterType ##{{{
	## initialize, description
	# n: name, s: size
	def initialize(n,s,offset,access); ##{{{
		puts "#{__FILE__}:(initialize) is not ready yet."
	end ##}}}

	## field(name,**opts={}), define a new attribute indicates to the register field
	## example:
	##	register 'name',:size=>'xx',:offset=>'xxx',:access=>'xxx' do
	##		field 'xxx', :bitOffSet=>'xx',:bitWidth=>'xx',:access=>'xxx',:reset=>'xx'
	##		...
	##	end
	def field(name,**opts={}); ##{{{
		puts "#{__FILE__}:(field(name,**opts={})) is not ready yet."
	end ##}}}


end ##}}}