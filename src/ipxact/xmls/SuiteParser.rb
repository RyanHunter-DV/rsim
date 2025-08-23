require_relative '../test'
# IP-XACT TestSuite Parser
# Parses TestSuite objects to IP-XACT XML format and vice versa
class SuiteParser
	attr_accessor :xml_parser, :test_suite, :database_dir, :app

	def initialize(obj_or_name, database_dir, app)
		@app = app
		@database_dir = database_dir
		if obj_or_name.is_a?(String)
			@suite = nil
			@xml_parser = XmlParser.new(File.join(@database_dir, "suite-#{obj_or_name}.xml"))
		else
			@suite = obj_or_name
			@xml_parser = XmlParser.new(File.join(@database_dir, "suite-#{@suite.name}.xml"))
		end
	end

	# Parse TestSuite object to IP-XACT XML format
	def parse_to_xml()
		@app.info("Parsing test suite #{@suite.name} to IP-XACT XML", 8)
		
		# Build IP-XACT test suite structure
		build_test_suite_xml(@suite)
		@xml_parser.write_to_file
		
		@app.info("Test suite #{@suite.name} parsed to XML successfully", 8)
	end

	# Read IP-XACT XML file and create TestSuite object
	def read_from_xml
		@app.info("Reading test suite from IP-XACT XML", 8)
		
		xml_data = @xml_parser.read_from_file
		test_suite = build_test_suite_from_xml(xml_data)
		
		@app.info("Test suite created from XML successfully", 8)
		test_suite
	end

private

	def build_test_suite_xml(suite)
		@xml_parser.header '<?xml version="1.0" encoding="UTF-8"?>'
		@xml_parser.header %Q|<ipxact:suite xmlns:ipxact="http://www.accellera.org/XMLSchema/IPXACT/1685-2014">|

		@xml_parser.add_tag('suite', :descp => suite.description)
		
		# Test suite identification
		@xml_parser.add_tag('vendor',:value=> suite.vendor, :parent=>'suite')
		@xml_parser.add_tag('library', :value=>suite.library, :parent=>'suite')
		@xml_parser.add_tag('name', :value=>suite.name, :parent=>'suite')
		@xml_parser.add_tag('version', :value=>suite.version, :parent=>'suite')
		@xml_parser.add_tag('nodePath', :value => suite.node_path, :parent => 'suite')
		
		# Test templates
		if suite.respond_to?(:templates) && suite.templates && !suite.templates.empty?
			@xml_parser.add_tag('templates', :parent => 'suite')
			suite.templates.each do |template_name, template|
				build_test_template_xml(template_name, template)
			end
		end
		
		# Test cases
		if suite.tests && !suite.tests.empty?
			@xml_parser.add_tag('testcases', :parent => 'suite')
			suite.tests.each do |test_case_name, test_case|
				build_test_case_xml(test_case_name, test_case)
			end
		end
	end

	def build_test_template_xml(name, template)
		@xml_parser.add_tag('template', :parent => 'templates')
		@xml_parser.add_tag('name', :value => name, :parent => 'template')
		@xml_parser.add_tag('description', :value => template.description, :parent => 'template')
		
		# Template parameters
		if template.parameters && !template.parameters.empty?
			@xml_parser.add_tag('parameters', :parent => 'template')
			template.parameters.each do |param_name, param_value|
				@xml_parser.add_tag('parameter', :parent => 'parameters')
				@xml_parser.add_tag('name', :value => param_name, :parent => 'parameter')
				@xml_parser.add_tag('value', :value => param_value.to_s, :parent => 'parameter')
			end
		end
		if template.run_args && !template.run_args.empty?
			@xml_parser.add_tag('args', :parent => 'template')
			template.run_args.each do |arg|
				@xml_parser.add_tag('arg', :value => arg, :parent => 'args')
			end
		end
		
		# Template configuration
		if template.config_name
			@xml_parser.add_tag('config', :value => template.config_name.to_s, :parent => 'template')
		end
	end

	def build_test_case_xml(name, test_case)
		@xml_parser.add_tag('testcase', :parent => 'testcases')
		@xml_parser.add_tag('name', :value => name, :parent => 'testcase')
		@xml_parser.add_tag('description', :value => test_case.description, :parent => 'testcase')
		
		# Test case parameters
		if test_case.parameters && !test_case.parameters.empty?
			@xml_parser.add_tag('parameters', :parent => 'testcase')
			test_case.parameters.each do |param_name, param_value|
				@xml_parser.add_tag('parameter', :parent => 'parameters')
				@xml_parser.add_tag('name', :value => param_name, :parent => 'parameter')
				if param_value.is_a?(Proc)
					@xml_parser.add_tag('value', :value => 'dynamic', :parent => 'parameter')
					@xml_parser.add_tag('dynamic', :value => 'true', :parent => 'parameter')
				else
					@xml_parser.add_tag('value', :value => param_value.to_s, :parent => 'parameter')
					@xml_parser.add_tag('dynamic', :value => 'false', :parent => 'parameter')
				end
			end
		end
		if test_case.run_args && !test_case.run_args.empty?
			@xml_parser.add_tag('args', :parent => 'testcase')
			test_case.run_args.each do |arg|
				@xml_parser.add_tag('arg', :value => arg, :parent => 'args')
			end
		end
		
		# Test template reference
		if test_case.test_template_ref
			@xml_parser.add_tag('templateRef', :value => test_case.test_template_ref, :parent => 'testcase')
		end
		
		# Configuration reference
		if test_case.config_name
			@xml_parser.add_tag('config', :value => test_case.config_name.to_s, :parent => 'testcase')
		end
	end


	def build_test_suite_from_xml(xml_data)
		# Parse XML data and create TestSuite object
		# This is a simplified implementation - in production you'd use a proper XML parser
		
		# Validate input XML data
		unless xml_data && !xml_data.empty?
			raise ArgumentError, "XML data cannot be nil or empty"
		end
		
		suite_name = @xml_parser.extract_vlnv(xml_data)
		node_path = @xml_parser.extract_value(xml_data, 'nodePath')
		description = @xml_parser.extract_value(xml_data, 'description') rescue "Test suite created from XML"

		# Validate required fields
		unless suite_name && node_path
			raise ArgumentError, "Suite name and node path are required"
		end

		suite = TestSuite.new(suite_name, node_path)
		suite.description(description)
		
		# Extract test templates
		templates_data = @xml_parser.extract_section(xml_data, 'templates')
		if templates_data
			templates_data.scan(/<template>(.*?)<\/template>/m) do |template_content|
				template_name = @xml_parser.extract_value(template_content[0], 'name')
				template = TestTemplate.new(template_name, suite)
				
				# Extract template description
				template_desc = @xml_parser.extract_value(template_content[0], 'description') rescue "Template #{template_name}"
				template.description(template_desc)
				
				# Extract template parameters
				params_data = @xml_parser.extract_section(template_content[0], 'parameters')
				if params_data
					params_data.scan(/<parameter>(.*?)<\/parameter>/m) do |param_content|
						param_name = @xml_parser.extract_value(param_content[0], 'name')
						param_value = @xml_parser.extract_value(param_content[0], 'value')
						template.parameter(param_name, param_value)
					end
				end
				if template.run_args && !template.run_args.empty?
					@xml_parser.add_tag('args', :parent => 'template')
					template.run_args.each do |arg|
						@xml_parser.add_tag('arg', :value => arg, :parent => 'args')
					end
				end
				
				# Extract template configuration
				config_name = @xml_parser.extract_value(template_content[0], 'config') rescue nil
				template.config(config_name) if config_name
				
				suite.templates[template_name] = template
			end
		end
		
		# Extract test cases
		test_cases_data = @xml_parser.extract_section(xml_data, 'testcases')
		if test_cases_data
			test_cases_data.scan(/<testcase>(.*?)<\/testcase>/m) do |test_case_content|
				test_case_name = @xml_parser.extract_value(test_case_content[0], 'name')
				test_case = TestCase.new(test_case_name, suite)
				
				# Validate that the test case object was created successfully
				unless test_case && test_case.respond_to?(:run_args)
					puts "Warning: Test case '#{test_case_name}' was not created properly or missing run_args method"
					next
				end
				
				# Extract test case description
				case_desc = @xml_parser.extract_value(test_case_content[0], 'description') rescue "Test case #{test_case_name}"
				test_case.description(case_desc)
				
				# Extract test case parameters
				params_data = @xml_parser.extract_section(test_case_content[0], 'parameters')
				if params_data
					params_data.scan(/<parameter>(.*?)<\/parameter>/m) do |param_content|
						param_name = @xml_parser.extract_value(param_content[0], 'name')
						param_value = @xml_parser.extract_value(param_content[0], 'value')
						is_dynamic = @xml_parser.extract_value(param_content[0], 'dynamic')
						
						if is_dynamic == 'true'
							# For dynamic parameters, create a simple block that returns the stored value
							test_case.parameter(param_name) { param_value }
						else
							test_case.parameter(param_name, param_value)
						end
					end
				end
				# Extract <arg> tags from the testcase XML and store to test_case
				args_data = @xml_parser.extract_section(test_case_content[0], 'args')
				if args_data && !args_data.empty?
					extracted_args = extract_arguments_from_xml(args_data)
					extracted_args.each do |arg_value|
						if validate_argument_value(arg_value)
							test_case.run_args(arg_value)
						else
							puts "Warning: Invalid argument value '#{arg_value}' for test case '#{test_case_name}'"
						end
					end
				end
				
				# Extract template reference
				template_ref = @xml_parser.extract_value(test_case_content[0], 'templateRef') rescue nil
				test_case.test_template_ref= template_ref if template_ref
				
				# Initialize parameters from template if template reference exists
				if template_ref
					test_case.init_parameters_by_template
				end
				
				# Extract configuration reference
				config_name = @xml_parser.extract_value(test_case_content[0], 'config') rescue nil
				test_case.config_name= config_name if config_name
				
				suite.register_testcase(test_case)
			end
		end
		
		# Log summary of extracted test cases and their arguments
		suite.tests.each do |test_name, test_case|
			args_count = test_case.get_run_args.length
			puts "Test case '#{test_name}' has #{args_count} run arguments" if args_count > 0
		end
		
		# Print detailed summary
		print_test_suite_summary(suite)
		
		suite
	end
	
	private
	
	# Validate argument value
	def validate_argument_value(arg_value)
		# Basic validation: argument should not be nil, empty, or contain only whitespace
		return false if arg_value.nil?
		return false if arg_value.to_s.strip.empty?
		
		# Additional validation: check for common problematic characters
		# This can be extended based on your specific requirements
		problematic_chars = ['<', '>', '"', "'", '&']
		problematic_chars.each do |char|
			return false if arg_value.to_s.include?(char)
		end
		
		# Check for reasonable length (prevent extremely long arguments)
		return false if arg_value.to_s.length > 1000
		
		true
	end
	
	# Print detailed summary of test suite
	def print_test_suite_summary(suite)
		puts "\n=== Test Suite Summary ==="
		puts "Suite: #{suite.name}"
		puts "Node Path: #{suite.node_path}"
		puts "Description: #{suite.description}"
		puts "Templates: #{suite.templates.keys.join(', ')}"
		puts "Test Cases: #{suite.tests.keys.join(', ')}"
		
		puts "\n=== Test Cases Details ==="
		suite.tests.each do |test_name, test_case|
			puts "  #{test_name}:"
			puts "    Description: #{test_case.description}"
			puts "    Template Ref: #{test_case.test_template_ref || 'None'}"
			puts "    Config: #{test_case.config_name || 'None'}"
			puts "    Parameters: #{test_case.parameters.keys.join(', ')}"
			puts "    Run Args: #{test_case.get_run_args.join(' ')}"
		end
		puts "========================\n"
	end
	
	# Extract arguments from XML with different formats
	def extract_arguments_from_xml(args_data)
		arguments = []
		
		# Try different XML patterns
		patterns = [
			/<arg(?:\s+[^>]*)?>(.*?)<\/arg>/m,  # Standard content tags
			/<arg(?:\s+[^>]*)?\s*\/>/,           # Self-closing tags
			/<arg\s+value=["']([^"']*)["']/,     # Tags with value attribute
			/<arg\s+content=["']([^"']*)["']/    # Tags with content attribute
		]
		
		patterns.each do |pattern|
			args_data.scan(pattern) do |match|
				arg_value = match[0] ? match[0].strip : ''
				arguments << arg_value unless arg_value.empty?
			end
		end
		
		arguments.uniq  # Remove duplicates
	end
end
