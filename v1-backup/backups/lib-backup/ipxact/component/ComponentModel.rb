"""
# Object description:
ComponentModel, object to store data that described by user command: model in component
"""
class ComponentModel ##{{{

	attr :ports;

	## initialize, 
	def initialize; ##{{{
		@ports={};
	end ##}}}


	## wire, user command, describe a WirePort typed object
	# format: wire <id>,<dir>, opts
	# support opts:
	# -:width=>[l,r]
	# -:displayName=>'xxx'
	def wire(id,dir,**opts); ##{{{
		#TODO, this WirePort type will be the same class as the port object in busDefinition, plan to redefine the WirePort object.
		# id is mandatory and for the portName in IP-XACT.
		# 1.build a WirePort object
		# 2.search options, then set the port attr to the built port object, like: port.setAttr(:attrname,<value>)
	end ##}}}
end ##}}}
