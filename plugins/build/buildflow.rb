flow :buildflow do ##{{{

	step :elaborate do ##{{{
		#TODO, step to elaborating the loaded nodes by calling the DataBase module's elaborate method.
		DataBase.elaborate;
	end ##}}}

	# to generate commands for building components
	#TODO
	step :buildComponents do ##{{{
		#1.build component root dir, out[:components] -> out/components
		#2.build component instance based on given config.
		#2.1.config.needs.each -> o.build TODO, component instance requires build method.
		#2.2.build component dir first, out/components/<component name>-<instance name>
		#2.3.write the generate command according to given generator.
	end ##}}}
end ##}}}