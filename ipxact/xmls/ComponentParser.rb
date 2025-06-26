
# IP-XACT Component Parser
# Parses Component objects to IP-XACT XML format and vice versa
class ComponentParser
	attr_accessor :xml_parser, :component, :database_dir

	def initialize(component, database_dir)
		@component = component
		@database_dir = database_dir
		@xml_parser = XmlParser.new(File.join(database_dir, "#{component.name}.xml"))
	end

	# Parse Component object to IP-XACT XML format
	def parse_to_xml()
		NodeApp.info("Parsing component #{@component.name} to IP-XACT XML", 8)
		
		# Build IP-XACT component structure
		build_component_xml(@component)
		@xml_parser.write_to_file
		
		NodeApp.info("Component #{@component.name} parsed to XML successfully", 8)
	end

	# Read IP-XACT XML file and create Component object
	def read_from_xml
		NodeApp.info("Reading component from IP-XACT XML", 8)
		
		xml_data = @xml_parser.read_from_file
		component = build_component_from_xml(xml_data)
		
		NodeApp.info("Component created from XML successfully", 8)
		component
	end

private

	def build_component_xml(component)
		@xml_parser.header '<?xml version="1.0" encoding="UTF-8"?>'
		@xml_parser.header %Q|<ipxact:component xmlns:ipxact="http://www.accellera.org/XMLSchema/IPXACT/1685-2014">|

		@xml_parser.add_tag('component',:descp=>component.description)
		# Component identification
		@xml_parser.add_tag('vendor',:value=> component.vendor, :parent=>'component')
		@xml_parser.add_tag('library', :value=>component.library, :parent=>'component')
		@xml_parser.add_tag('name', :value=>component.name, :parent=>'component')
		@xml_parser.add_tag('version', :value=>component.version, :parent=>'component')
		# Component model
		@xml_parser.add_tag('model',:parent=>'component')
		
		# Views
		if component.views && !component.views.empty?
			@xml_parser.add_tag('views',:parent=>'model')
			component.views.each do |view_name, view|
				build_view_xml(view_name,view);
			end
		end
		# File sets
		if component.file_sets && !component.file_sets.empty?
			@xml_parser.add_tag('fileSets',:parent=>'component')
			component.file_sets.each do |file_set_name, file_set|
				build_file_set_xml(file_set_name,file_set);
			end
		end
	end

	def build_view_xml(name,o)
		@xml_parser.add_tag('view',:parent=>'views')
		@xml_parser.add_tag('envIdentifier',:value=>name,:parent=>'view')
		
		
		# File sets
		if o.file_sets && !o.file_sets.empty?
			@xml_parser.add_tag('fileSetRef',:parent=>'view')
			o.file_sets.each do |file_set_name, file_set|
				@xml_parser.add_tag('localName',:value=>file_set_name,:parent=>'fileSetRef')
			end
		end
	end

	# file_set is object of FileSet class
	def build_file_set_xml(name, file_set)
		@xml_parser.add_tag('fileSet', :parent=>'fileSets')
		@xml_parser.add_tag('name', :value=>name, :parent=>'fileSet')
		
		# Files
		if file_set.sources && !file_set.sources.empty?
			@xml_parser.add_tag('file', :parent=>'fileSet')
			file_set.sources.each do |type, files|
				files.each do |file_name, opts|
					@xml_parser.add_tag('name', :value=>file_name, :parent=>'file')
					@xml_parser.add_tag('fileType', :value=>opts[:type].to_s, :parent=>'file')
					@xml_parser.add_tag('isIncludeFile', :value=>'false', :parent=>'file')
					if opts[:incdir]
						@xml_parser.add_tag('includePath', :value=>file_set.root_path, :parent=>'file')
					end
				end
			end
			#TODO, need add file_set.includes later.
		end
	end
	def build_component_from_xml(xml_data)
		# Parse XML data and create Component object
		# This is a simplified implementation - in production you'd use a proper XML parser
		
		component_name = extract_value(xml_data, 'ipxact:name')
		component = Component.new(component_name, @database_dir)
		
		# Extract views
		views_data = extract_section(xml_data, 'ipxact:views')
		if views_data
			views_data.scan(/<ipxact:view>(.*?)<\/ipxact:view>/m) do |view_content|
				view_name = extract_value(view_content[0], 'ipxact:name')
				view = View.new(view_name, component)
				
				# Extract file set references
				file_set_refs = extract_section(view_content[0], 'ipxact:fileSetRef')
				if file_set_refs
					file_set_refs.scan(/<ipxact:localName>(.*?)<\/ipxact:localName>/) do |file_set_name|
						view.fileSet(file_set_name[0])
					end
				end
				
				component.views[view_name] = view
			end
		end
		
		component
	end

	def extract_value(xml_content, tag_name)
		match = xml_content.match(/<#{tag_name}>(.*?)<\/#{tag_name}>/m)
		match ? match[1].strip : nil
	end

	def extract_section(xml_content, section_name)
		match = xml_content.match(/<#{section_name}>(.*?)<\/#{section_name}>/m)
		match ? match[1] : nil
	end
end
