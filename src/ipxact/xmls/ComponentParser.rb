require_relative '../component'
# IP-XACT Component Parser
# Parses Component objects to IP-XACT XML format and vice versa
class ComponentParser
	attr_accessor :xml_parser, :component, :database_dir, :app

	def initialize(obj_or_name, database_dir,app)
		@app = app
		@database_dir = database_dir
		if obj_or_name.is_a?(String)
			@component = nil
			@xml_parser = XmlParser.new(File.join(@database_dir, "component-#{obj_or_name}.xml"))
		else
			@component = obj_or_name
			@xml_parser = XmlParser.new(File.join(@database_dir, "component-#{@component.name}.xml"))
		end
	end

	# Parse Component object to IP-XACT XML format
	def parse_to_xml()
		@app.info("Parsing component #{@component.name} to IP-XACT XML", 8)
		
		# Build IP-XACT component structure
		build_component_xml(@component)
		@xml_parser.write_to_file
		
		@app.info("Component #{@component.name} parsed to XML successfully", 8)
	end

	# Read IP-XACT XML file and create Component object
	def read_from_xml
		@app.info("Reading component from IP-XACT XML", 8)
		
		xml_data = @xml_parser.read_from_file
		component = build_component_from_xml(xml_data)
		
		@app.info("Component created from XML successfully", 8)
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
		@xml_parser.add_tag('nodePath', :value=>component.node_path, :parent=>'component')
		
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
		##@xml_parser.add_tag('nodePath', :value=>file_set.root_path, :parent=>'fileSet')
		
		# Files
		if file_set.sources && !file_set.sources.empty?
			file_set.sources.each do |type, files|
				files.each do |file_name, opts|
					@xml_parser.add_tag('file', :parent=>'fileSet')
					@xml_parser.add_tag('name', :value=>file_name, :parent=>'file')
					@xml_parser.add_tag('fileType', :value=>opts[:type].to_s, :parent=>'file')
					@xml_parser.add_tag('isIncludeFile', :value=>'false', :parent=>'file')
					if opts[:incdir]
						@xml_parser.add_tag('includePath', :value=>file_set.root_path, :parent=>'file')
					end
				end
			end
		end
		# Includes
		if file_set.includes && !file_set.includes.empty?
			@xml_parser.add_tag('includes',:parent=>'fileSet')
			file_set.includes.each do |file_name|
				@xml_parser.add_tag('include',:value=>file_name,:parent=>'includes')
			end
		end
	end


	def build_component_from_xml(xml_data)
		# Parse XML data and create Component object
		# This is a simplified implementation - in production you'd use a proper XML parser
		
		component_name = @xml_parser.extract_vlnv(xml_data)
		
		# Extract views
		views_data = @xml_parser.extract_section(xml_data, 'views')
		node_path = @xml_parser.extract_value(xml_data, 'nodePath')

		component = Component.new(component_name, node_path)
		if views_data
			views_data.scan(/<view>(.*?)<\/view>/m) do |view_content|
				view_name = @xml_parser.extract_value(view_content[0], 'envIdentifier')
				view = View.new(view_name, component)
				
				# Extract file set references
				file_set_refs = @xml_parser.extract_section(view_content[0], 'fileSetRef')
				if file_set_refs
					file_set_refs.scan(/<name>(.*?)<\/name>/) do |file_set_name|
						view.fileSet(file_set_name[0])
					end
				end
				
				component.views[view_name] = view
			end
		end
		file_sets_data = @xml_parser.extract_section(xml_data, 'fileSets')
		if file_sets_data
			file_set_content= @xml_parser.extract_section(file_sets_data, 'fileSet')
			file_set_name = @xml_parser.extract_value(file_set_content, 'name')
			#root_path = @xml_parser.extract_value(file_set_content, 'nodePath')
			file_set = FileSet.new(file_set_name, component)
			# extract the file from given content.
			files=@xml_parser.extract_section(file_set_content, 'file',false)
			files=[files] unless files.is_a?(Array);
			files.each do |file|
				file_name = @xml_parser.extract_value(file, 'name')
				file_type = @xml_parser.extract_value(file, 'fileType')
				file_set.file(file_name, file_type)
				@app.debug("File: #{file_name} type: #{file_type}", 5)
			end
			includes=@xml_parser.extract_section(file_set_content, 'include',false)
			includes=[includes] unless includes.is_a?(Array);
			includes.each do |include|
				file_set.incdir(@xml_parser.extract_value(include, 'include'))
			end
			component.file_sets[file_set_name] = file_set
		end
		
		component
	end


end
