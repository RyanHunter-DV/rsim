class View < IpxBaseObject
	attr :component;
	attr :file_sets;

	def initialize(name,component)
		super(component.node_path);
		@component = component;
		@file_sets = {};
		set_xml_fields(name)
	end
	# for xml fields
	def set_xml_fields(name)
		self.define_singleton_method(:envIdentifier) do
			name;
		end
	end

	# user command of view:
	# fileSet xxx, specify the file set name, which will be found from the component.
	# but need after the component is evaluated.
	def fileSet(name=nil)
		return @file_sets.keys if name.nil?
		# sets link name to file_sets hash.
		@file_sets[name.to_s] = nil;
	end

	#def finalize
	#	NodeApp.info("Finalizing view #{self.name}", 8)
	#	@file_sets.each do |name, file_set|
	#		if @component.file_sets[name]
	#			RsApp.info("Linking file set #{name} to view #{self.name}", 5)
	#			@file_sets[name] = @component.file_sets[name]
	#		else
	#			raise IpxException.new("File set '#{name}' not found in component '#{@component.name}'")
	#		end
	#	end
	#	RsApp.info("Finalizing view #{self.name} done", 8)
	#end
end