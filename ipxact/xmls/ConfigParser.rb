class ConfigParser
	attr_accessor :xml_parser, :config, :database_dir, :app

	def initialize(obj_or_name, database_dir,app)
		@app = app
		@database_dir = database_dir
		if obj_or_name.is_a?(String)
			@config = nil
			@xml_parser = XmlParser.new(File.join(@database_dir, "#{obj_or_name}.xml"))
		else
			@config = obj_or_name
			@xml_parser = XmlParser.new(File.join(@database_dir, "#{@config.name}.xml"))
		end
	end

	def parse_to_xml()
		@app.info("Parsing config #{@config.name} to IP-XACT XML", 8)
		
		# Build IP-XACT config structure
		build_config_xml(@config)
		@xml_parser.write_to_file
		
		@app.info("Config #{@config.name} parsed to XML successfully", 8)
	end
	def read_from_xml
		@app.info("Reading config from IP-XACT XML", 8)
		config = build_config_from_xml(@xml_parser.read_from_file)
		@app.info("Config created from XML successfully", 8)
		config
	end

private

	def build_config_from_xml(xml_data)
		config_name = @xml_parser.extract_vlnv(xml_data)
		config = Config.new(config_name, @database_dir)
		designRef = @xml_parser.extract_value(xml_data, 'designRef')
		config.designRef(designRef)
		viewConfiguration = @xml_parser.extract_section(xml_data, 'viewConfiguration')
		if viewConfiguration
			instance_name=nil;
			view_name=nil;
			viewConfiguration.scan(/<instanceName>(.*?)<\/instanceName>/) do |instanceName|
				instance_name=instanceName[0];
			end
			viewConfiguration.scan(/<viewName>(.*?)<\/viewName>/) do |viewName|
				view_name=viewName[0];
			end
			config.need(instance_name, :as=>view_name);
		end
		config
	end

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