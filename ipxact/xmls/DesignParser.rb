class DesignParser
	attr_accessor :xml_parser, :design, :database_dir

	def initialize(design, database_dir)
		@design = design
		@database_dir = database_dir
		@xml_parser = XmlParser.new(File.join(database_dir, "#{design.name}.xml"))
	end

	def parse_to_xml()
		NodeApp.info("Parsing design #{@design.name} to IP-XACT XML", 8)
		
		# Build IP-XACT design structure
		build_design_xml(@design)
		@xml_parser.write_to_file
		
		NodeApp.info("Design #{@design.name} parsed to XML successfully", 8)
	end

private

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
			@xml_parser.add_tag('componentInstance',:value=>opts[:as], :parent=>'componentInstances')
			@xml_parser.add_tag('componentRef',:value=>name, :parent=>'componentInstances')
		end
	end
end