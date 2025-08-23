require_relative 'xmls/init'
class MetaDatabase
	attr_accessor :components;
	attr_accessor :configs;
	attr_accessor :suites;
	attr_accessor :design;

	attr :database_dir;
	attr :database_file;

	attr_accessor :app;
	def initialize(out_home,app,create=true)
		@app = app;
		@components = {};
		@suites={};
		@configs = {};
		@design=nil;
		setup_database(out_home,create)
	end

	def setup_database(out_home,create)
		@database_dir = File.join(out_home, 'meta')
		FileUtils.mkdir_p(@database_dir) if create
		@database_file = File.join(@database_dir, 'meta.db')
		FileUtils.touch(@database_file) if create
	end

	def link_design(c)
		raise IpxException.new("design must declare before link_design") if @design.nil?
		c.design @design;
	end

	# register component need to build a meta database file to record
	# all key messages into the data file.
	def register(type,c)
		@app.debug("[DB_REGISTER] Registering component of type '#{type}'", 9)
		type = type.to_s;
		@app.debug("[DB_TYPE_CONV] Type converted to string: '#{type}'", 9)
		parser_class_name = "#{type.capitalize}Parser"
		@app.debug("[DB_PARSER_LOOKUP] Looking for parser class: '#{parser_class_name}'", 9)
		parser_class = Object.const_get(parser_class_name)
		@app.debug("[DB_PARSER_FOUND] Found parser class: #{parser_class}", 9)
		p = parser_class.new(c, @database_dir,@app)
		@app.debug("[DB_PARSER_INSTANCE] Created parser instance: #{p.class}", 9)
		@app.debug("[DB_DESIGN_CHECK] Current design: #{@design ? @design.class : 'nil'}", 9)
		@design=c if type=='design';
		p.parse_to_xml()
		@app.debug("[DB_PARSE_COMPLETE] Completed parse_to_xml for #{type}", 9)
	end

	def find(type,name=nil,opts={})
		message= "find_#{type}";
		self.send(message,name,opts)
	end
	def find_by_name(type,name=nil)
		message= "find_#{type}";
		self.send(message,name,:use_name=>true)
	end
	def find_config(name=nil,opts={})
		@app.debug("[DB_FIND_CONFIG] Finding config: #{name}", 9)
		@app.debug("[DB_FIND_CONFIG] Options: #{opts}", 9)
		@app.debug("[DB_FIND_CONFIG] Configs: #{@configs}", 9)
		if opts[:use_name]
			@configs.keys.each do |vlnv|
				config_name = vlnv.split('/')[2]  # Extract name from VLNV (vendor/library/name/version)
				return @configs[vlnv] if config_name == name
			end
		else
			return @configs[name] if @configs.has_key?(name)
		end
		raise IpxException.new("Config '#{name}' not found")
	end
	def find_design(name=nil,opts={})
		@app.debug("[DB_FIND_DESIGN] Finding design: #{name}", 9)
		@app.debug("[DB_FIND_DESIGN] Options: #{opts}", 9)
		@app.debug("[DB_FIND_DESIGN] Designs: #{@design}", 9)
		return @design if @design.vlnv==name
		raise IpxException.new("Design '#{name}' not found")
	end
	def find_component(name=nil,opts={})
		@app.debug("[DB_FIND_COMPONENT] Finding component: #{name}", 9)
		@app.debug("[DB_FIND_COMPONENT] Options: #{opts}", 9)
		@app.debug("[DB_FIND_COMPONENT] Components: #{@components}", 9)
		#return @components[name] if @components.has_key?(name)
		if opts[:use_name]
			@components.keys.each do |vlnv|
				component_name = vlnv.split('/')[2]  # Extract name from VLNV (vendor/library/name/version)
				return @components[vlnv] if component_name == name
			end
		else
			return @components[name] if @components.has_key?(name)
		end
		raise IpxException.new("Component '#{name}' not found")
	end
	def find_suite(name=nil,opts={})
		@app.debug("[DB_FIND_SUITE] Finding suite: #{name}", 9)
		@app.debug("[DB_FIND_SUITE] Options: #{opts}", 9)
		@app.debug("[DB_FIND_SUITE] Suites: #{@suites}", 9)
		if opts[:use_name]
			@suites.keys.each do |vlnv|
				suite_name = vlnv.split('/')[2]  # Extract name from VLNV (vendor/library/name/version)
				return @suites[vlnv] if suite_name == name
			end
		else
			return @suites[name] if @suites.has_key?(name)
		end
		raise IpxException.new("Suite '#{name}' not found")
	end

	def extract_root(xml_file)
		#extract the root tag from given xml_file.
		xml_content=File.read(xml_file);
		puts "xml_content: #{xml_content}"
		root_element=xml_content.match(/<root:(\w+) .*>/m)[1]
		puts "root_element: (#{root_element})"
		root_element
	end

	def read_from_xml
		app.debug("[DB_READ_XML] Starting to read XML files from database directory: #{@database_dir}", 9)
		
		# Read all XML files from the database directory
		xml_files = Dir.glob(File.join(@database_dir, "*.xml"))
		app.debug("[DB_XML_FILES] Found #{xml_files.length} XML files", 9)
		
		xml_files.each do |xml_file|
			begin
				app.debug("[DB_PROCESSING] Processing XML file: #{File.basename(xml_file)}", 9)
				
				# Read and parse the XML file
				root_element=extract_root(xml_file);

				
				# Determine the type from the root element name
				type = root_element.downcase
				app.debug("[DB_XML_TYPE] Detected type from XML: '#{type}'", 9)
				
				# Get the appropriate parser class
				parser_class_name = "#{type.capitalize}Parser"
				app.debug("[DB_PARSER_LOOKUP] Looking for parser class: '#{parser_class_name}'", 9)
				
				begin
					parser_class = Object.const_get(parser_class_name)
					app.debug("[DB_PARSER_FOUND] Found parser class: #{parser_class}", 9)
					
					# Create parser instance and read from XML

					object_name = File.basename(xml_file.sub(type+'-',''), '.xml')
					parser = parser_class.new(object_name, @database_dir,@app)
					app.debug("[DB_PARSER_INSTANCE] Created parser instance: #{parser.class}", 9)
					
					# Read the object from XML
					obj = parser.read_from_xml()
					app.debug("[DB_OBJECT_CREATED] Created object: #{obj.class}", 9)
					
					# Store the object based on its type
					case type
					when 'design'
						@design = obj
						app.debug("[DB_DESIGN_STORED] Stored design object", 9)
					when 'component'
						component_name = obj.vlnv || File.basename(xml_file.sub('component-',''), '.xml')
						@components[component_name] = obj
						app.debug("[DB_COMPONENT_STORED] Stored component '#{component_name}'", 9)
					when 'suite'
						suite_name = obj.vlnv || File.basename(xml_file.sub('suite-',''), '.xml')
						@suites[suite_name] = obj
						app.debug("[DB_SUITE_STORED] Stored suite '#{suite_name}'", 9)
					when 'config'
						config_name = obj.vlnv || File.basename(xml_file.sub('config-',''), '.xml')
						@configs[config_name] = obj
						app.debug("[DB_CONFIG_STORED] Stored config '#{config_name}'", 9)
					else
						app.debug("[DB_UNKNOWN_TYPE] Unknown type '#{type}', skipping", 9)
						raise IpxException.new("Unknown type '#{type}'")
					end
					
				rescue NameError => e
					app.debug("[DB_PARSER_NOT_FOUND] Parser class '#{parser_class_name}' not found: #{e.message}", 9)
					app.debug("[DB_PARSER_NOT_FOUND] Stack trace: #{e.backtrace.join("\n")}", 9)
				end
				
			rescue => e
				app.debug("[DB_XML_ERROR] Error processing XML file '#{xml_file}': #{e.message}", 9)
				app.debug("[DB_XML_ERROR] Stack trace: #{e.backtrace.join("\n")}", 9)
			end
		end
		
	end


private

end