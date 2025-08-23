require_relative '../design'
class DesignParser
	attr_accessor :xml_parser, :design, :database_dir, :app

	def initialize(obj_or_name, database_dir,app)
		@app = app
		@database_dir = database_dir
		if obj_or_name.is_a?(String)
			@design = nil
			@xml_parser = XmlParser.new(File.join(@database_dir, "design-#{obj_or_name}.xml"))
		else
			@design = obj_or_name
			@xml_parser = XmlParser.new(File.join(@database_dir, "design-#{@design.name}.xml"))
		end
	end

	def parse_to_xml()
		@app.info("Parsing design #{@design.name} to IP-XACT XML", 8)
		# Build IP-XACT design structure
		build_design_xml(@design)
		@xml_parser.write_to_file
		@app.info("Design #{@design.name} parsed to XML successfully", 8)
	end

	def read_from_xml
		@app.info("Reading design from IP-XACT XML", 8)
		design = build_design_from_xml(@xml_parser.read_from_file)
		@app.info("Design created from XML successfully", 8)
		design
	end
private

	def build_design_from_xml(xml_data)
		design_name = @xml_parser.extract_vlnv(xml_data)
		design = Design.new(design_name, @database_dir)

		componentInstances = @xml_parser.extract_section(xml_data, 'componentInstances')
		if componentInstances
			component_instances = @xml_parser.extract_section(componentInstances, 'componentInstance',false)
			component_instances.each do |component_instance|
				instance_name = @xml_parser.extract_value(component_instance, 'instanceName')
				component_ref = @xml_parser.extract_value(component_instance, 'componentRef')
				design.instance(component_ref, :as=>instance_name)
			end
			#opts={};
			#componentInstances.scan(/<componentInstance>(.*?)<\/componentInstance>/) do |componentInstance|
			#	instance_name=componentInstance[0];
			#	opts[:as]=instance_name;
			#end
			#componentInstances.scan(/<componentRef>(.*?)<\/componentRef>/) do |componentRef|
			#	opts[:componentRef]=componentRef[0];
			#end
			#design.instance(opts[:componentRef],opts);
			@app.debug("design.instances: #{design.instances}", 9)
		end

		design
	end

	def build_design_xml(design)
		@xml_parser.header '<?xml version="1.0" encoding="UTF-8"?>'
		@xml_parser.header %Q|<ipxact:design xmlns:ipxact="http://www.accellera.org/XMLSchema/IPXACT/1685-2014">|
		@xml_parser.add_tag('design',:descp=>design.description)
		@xml_parser.add_tag('vendor',:value=>design.vendor, :parent=>'design')
		@xml_parser.add_tag('library',:value=>design.library, :parent=>'design')
		@xml_parser.add_tag('name',:value=>design.name, :parent=>'design')
		@xml_parser.add_tag('version',:value=>design.version, :parent=>'design')

		# instances
		@xml_parser.add_tag('componentInstances',:parent=>'design')
		design.instances.each do |name, opts|
			@xml_parser.add_tag('componentInstance',:parent=>'componentInstances')
			@xml_parser.add_tag('instanceName',:value=>name, :parent=>'componentInstance')
			@xml_parser.add_tag('componentRef',:value=>opts[:componentRef], :parent=>'componentInstance')
		end
	end
end