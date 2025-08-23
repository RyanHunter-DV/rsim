require_relative '../config'
class ConfigParser
	attr_accessor :xml_parser, :config, :database_dir, :app

	def initialize(obj_or_name, database_dir,app)
		@app = app
		@database_dir = database_dir
		if obj_or_name.is_a?(String)
			@config = nil
			@xml_parser = XmlParser.new(File.join(@database_dir, "config-#{obj_or_name}.xml"))
		else
			@config = obj_or_name
			@xml_parser = XmlParser.new(File.join(@database_dir, "config-#{@config.name}.xml"))
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
		
		# Extract design reference
		designRef = @xml_parser.extract_value(xml_data, 'designRef')
		config.designRef(designRef) if designRef
		
		# Extract view configurations
		viewConfigurations = @xml_parser.extract_section(xml_data, 'viewConfigurations')
		if viewConfigurations
			view_configurations = @xml_parser.extract_section(viewConfigurations, 'viewConfiguration', false)
			view_configurations.each do |view_configuration|
				instance_name = @xml_parser.extract_value(view_configuration, 'instanceName')
				view_name = @xml_parser.extract_value(view_configuration, 'viewName')
				config.need(instance_name, :as => view_name) if instance_name && view_name
			end
		end
		
		# Extract generator chain configuration with compile and elaborate options
		generatorChainConfiguration = @xml_parser.extract_section(xml_data, 'generatorChainConfiguration')
		if generatorChainConfiguration
			configurableElementValues = @xml_parser.extract_section(generatorChainConfiguration, 'configurableElementValues', false)
			configurableElementValues.each do |configurableElementValue|
				# Extract compile options for different simulators
				extract_compile_options(config, configurableElementValue)
				
				# Extract elaborate options for different simulators
				extract_elaborate_options(config, configurableElementValue)
			end
		end
		
		config
	end

	def extract_compile_options(config, xml_content)
		# Extract VCS compile options
		vcs_compile_opts = extract_all_values(xml_content, 'vcs_compile_options')
		vcs_compile_opts.each do |opt|
			config.vcs_compile_options(opt) if opt && !opt.empty?
		end
		
		# Extract Xcelium compile options
		xlm_compile_opts = extract_all_values(xml_content, 'xlm_compile_options')
		xlm_compile_opts.each do |opt|
			config.xlm_compile_options(opt) if opt && !opt.empty?
		end
		
		# Extract generic compile options (for future extensibility)
		generic_compile_opts = extract_all_values(xml_content, 'compile_options')
		generic_compile_opts.each do |opt|
			# Default to VCS if no specific simulator is specified
			config.vcs_compile_options(opt) if opt && !opt.empty?
		end
	end

	def extract_elaborate_options(config, xml_content)
		# Extract VCS elaborate options
		vcs_elab_opts = extract_all_values(xml_content, 'vcs_elab_options')
		vcs_elab_opts.each do |opt|
			config.vcs_elab_options(opt) if opt && !opt.empty?
		end
		
		# Extract Xcelium elaborate options
		xlm_elab_opts = extract_all_values(xml_content, 'xlm_elab_options')
		xlm_elab_opts.each do |opt|
			config.xlm_elab_options(opt) if opt && !opt.empty?
		end
		
		# Extract generic elaborate options (for future extensibility)
		generic_elab_opts = extract_all_values(xml_content, 'elab_options')
		generic_elab_opts.each do |opt|
			# Default to VCS if no specific simulator is specified
			config.vcs_elab_options(opt) if opt && !opt.empty?
		end
	end

	# Helper method to extract all values for a given tag name
	# This method handles multiple occurrences of the same tag
	def extract_all_values(xml_content, tag_name)
		values = []
		pos = 0
		
		while pos < xml_content.length
			# Find the next opening tag
			start_pos = xml_content.index(/<#{tag_name}(?:\s+[^>]*)?>/, pos)
			break if start_pos.nil?
			
			# Find the position after the opening tag
			opening_tag_end = xml_content.index('>', start_pos) + 1
			
			# Find the closing tag
			closing_tag_start = xml_content.index("</#{tag_name}>", opening_tag_end)
			break if closing_tag_start.nil?
			
			# Extract the value between tags
			value = xml_content[opening_tag_end...closing_tag_start].strip
			values << value if !value.empty?
			
			# Move to next position
			pos = closing_tag_start + "</#{tag_name}>".length
		end
		
		values
	end

	def build_config_xml(config)
		@xml_parser.header '<?xml version="1.0" encoding="UTF-8"?>'
		@xml_parser.header %Q|<ipxact:config xmlns:ipxact="http://www.accellera.org/XMLSchema/IPXACT/1685-2014">|
		
		@xml_parser.add_tag('config', :descp => config.description)
		@xml_parser.add_tag('vendor', :value => config.vendor, :parent => 'config')
		@xml_parser.add_tag('library', :value => config.library, :parent => 'config')
		@xml_parser.add_tag('name', :value => config.name, :parent => 'config')
		@xml_parser.add_tag('version', :value => config.version, :parent => 'config')
		
		@xml_parser.add_tag('designRef', :value => config.designRef, :parent => 'config')

		# need components
		@xml_parser.add_tag('viewConfigurations', :parent => 'config')
		if config.need_components && !config.need_components.empty?
			config.need_components.each do |inst_name, view|
				@xml_parser.add_tag('viewConfiguration', :parent => 'viewConfigurations')
				@xml_parser.add_tag('instanceName', :value => inst_name, :parent => 'viewConfiguration')
				@xml_parser.add_tag('viewName', :value => view, :parent => 'viewConfiguration')
			end
		end
		
		@xml_parser.add_tag('generatorChainConfiguration', :parent => 'config')
		#TODO, chainRef not support yet.
		@xml_parser.add_tag('configurableElementValues', :parent => 'generatorChainConfiguration')
		
		# Add compile options
		if config.compile_options && !config.compile_options.empty?
			config.compile_options.each do |simulator, options|
				options.each do |option|
					@xml_parser.add_tag(%Q|#{simulator}_compile_options|, :value => option, :parent => 'configurableElementValues')
				end
			end
		end
		
		# Add elaborate options
		if config.elaborate_options && !config.elaborate_options.empty?
			config.elaborate_options.each do |simulator, options|
				options.each do |option|
					@xml_parser.add_tag(%Q|#{simulator}_elab_options|, :value => option, :parent => 'configurableElementValues')
				end
			end
		end
	end
end