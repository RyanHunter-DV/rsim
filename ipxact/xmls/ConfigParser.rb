class ConfigParser
	attr_accessor :xml_parser, :config, :database_dir

	def initialize(config, database_dir)
		@config = config
		@database_dir = database_dir
		@xml_parser = XmlParser.new(File.join(database_dir, "#{config.name}.xml"))
	end

	def parse_to_xml()
		NodeApp.info("Parsing config #{@config.name} to IP-XACT XML", 8)
		
		# Build IP-XACT config structure
		build_config_xml(@config)
		@xml_parser.write_to_file
		
		NodeApp.info("Config #{@config.name} parsed to XML successfully", 8)
	end

private

	def build_config_xml(config)
		@xml_parser.header '<?xml version="1.0" encoding="UTF-8"?>'
		@xml_parser.header %Q|<ipxact:vendor xmlns:ipxact="http://www.accellera.org/XMLSchema/IPXACT/1685-2014">|
		
		@xml_parser.add_tag('config',:descp=>config.description)
		@xml_parser.add_tag('vendor',:value=>config.vendor, :parent=>'config')
		@xml_parser.add_tag('library', :value=>config.library, :parent=>'config')
		@xml_parser.add_tag('name', :value=>config.name, :parent=>'config')
		@xml_parser.add_tag('version', :value=>config.version, :parent=>'config')
		
		@xml_parser.add_tag('designRef',:value=>config.designRef, :parent=>'config')

		# need components
		@xml_parser.add_tag('viewConfiguration',:parent=>'config')
		if config.need_components && !config.need_components.empty?
			config.need_components.each do |inst_name, view|
				@xml_parser.add_tag('instanceName',:value=>inst_name, :parent=>'viewConfiguration')
				@xml_parser.add_tag('viewName',:value=>view, :parent=>'viewConfiguration')
			end
		end
	end
end