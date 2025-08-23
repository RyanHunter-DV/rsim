require_relative 'IpxBaseObject'
#class Test < IpxBaseObject
#	attr_accessor :test_templates;
#	attr_accessor :test_cases;
#	attr_accessor :description;
#	attr_accessor :parameters;
#	attr_accessor :file_sets;
#
#	def initialize(vlnv, p)
#		super(p);
#		@test_templates = {};
#		@test_cases = {};
#		@description = "This test specification is created by IP-XACT builder.";
#		@parameters = {};
#		@file_sets = {};
#		set_vlnv(vlnv.to_s);
#	end
#
#	def set_vlnv(vlnv)
#		_l = [:vendor, :library, :name, :version];
#		parts = vlnv.split('/')
#		raise IpxException.new("Invalid VLNV: #{vlnv}") if parts.length != _l.length
#		_l.each_with_index do |method_name, index|
#			define_singleton_method(method_name) do
#				parts[index]
#			end
#		end
#		define_singleton_method(:vlnv) do
#			parts.join('/')
#		end
#	end
#
#	def description(d = nil)
#		@description = d if d;
#		@description;
#	end
#
#	#not used, def test_bench(tb = nil)
#	#not used, 	@test_bench = tb if tb;
#	#not used, 	@test_bench;
#	#not used, end
#
#	# Support for test template definitions
#	def test_template(name, &block)
#		name = name.to_s;
#		tt = TestTemplate.new(name, self);
#		tt.instance_eval(&block) if block_given?;
#		@test_templates[name] = tt;
#		NodeApp.info("TestTemplate #{name} registered to test #{self.name}", 8);
#	end
#
#	# Support for test case definitions
#	def test_case(name, &block)
#		name = name.to_s;
#		tc = TestCase.new(name, self);
#		tc.instance_eval(&block) if block_given?;
#		@test_cases[name] = tc;
#		NodeApp.info("TestCase #{name} registered to test #{self.name}", 8);
#	end
#
#	# Support for parameter definitions
#	def parameter(name, value = nil, &block)
#		name = name.to_s;
#		if block_given?
#			@parameters[name] = block;
#		else
#			@parameters[name] = value;
#		end
#		NodeApp.info("Parameter #{name} registered to test #{self.name}", 8);
#	end
#
#	# Support for file set definitions
#	def file_set(name, &block)
#		name = name.to_s;
#		fs = FileSet.new(name, self);
#		fs.instance_eval(&block) if block_given?;
#		@file_sets[name] = fs;
#		NodeApp.info("FileSet #{name} registered to test #{self.name}", 8);
#	end
#
#	# Get test template by name
#	def get_test_template(name)
#		@test_templates[name.to_s] || raise(IpxException.new("TestTemplate #{name} not found in test #{self.name}"));
#	end
#
#	# Get test case by name
#	def get_test_case(name)
#		@test_cases[name.to_s] || raise(IpxException.new("TestCase #{name} not found in test #{self.name}"));
#	end
#
#	# Get parameter value
#	def get_parameter(name)
#		param = @parameters[name.to_s];
#		if param.is_a?(Proc)
#			param.call;
#		else
#			param;
#		end
#	end
#
#	# Check if test has specific test case
#	def has_test_case?(name)
#		@test_cases.has_key?(name.to_s);
#	end
#
#	# Check if test has specific test template
#	def has_test_template?(name)
#		@test_templates.has_key?(name.to_s);
#	end
#
#	# List all test case names
#	def test_case_names
#		@test_cases.keys;
#	end
#
#	# List all test template names
#	def test_template_names
#		@test_templates.keys;
#	end
#
#	# List all parameter names
#	def parameter_names
#		@parameters.keys;
#	end
#
#	# List all file set names
#	def file_set_names
#		@file_sets.keys;
#	end
#end

# TestTemplate class for defining test templates
class TestTemplate < IpxBaseObject
	attr_accessor :description;
	attr_accessor :parameters;
	attr_accessor :config_name;
	attr_accessor :parent;

	attr :run_args;
	def initialize(name, suite)
		super(suite.node_path);
		@name = name;
		@parent = suite;
		@description = "Test template #{name}";
		@parameters = {};
		@config_name = nil;
		@run_args = [];
	end

	def name
		@name;
	end

	def description(desc = nil)
		@description = desc if desc;
		@description;
	end

	def run_args(*args)
		return @run_args if not args or args.empty?;
		@run_args.append(*args);
		puts "[DEBUG] Adding run_args to '#{@name}': #{args.inspect}" if !args.empty?
	end
	
	# Clear all run arguments
	def clear_run_args
		@run_args = []
	end
	
	# Check if test case has any run arguments
	def has_run_args?
		!(@run_args.nil? || @run_args.empty?)
	end
	
	# Get run arguments as a space-separated string
	def run_args_string
		@run_args ? @run_args.join(' ') : ''
	end
	

	def config(name)
		@config_name = name.to_sym;
	end

	def parameter(name, value)
		name = name.to_s;
		@parameters[name] = value;
	end

	def get_parameter(name)
		param = @parameters[name.to_s];
		if param.is_a?(Proc)
			param.call;
		else
			param;
		end
	end
	
	# Getter method for run_args to access the current arguments
	def get_run_args
		@run_args || []
	end
end

# TestCase class for defining specific test cases
class TestCase < TestTemplate 
	attr_accessor :description;
	attr_accessor :parameters;
	attr_accessor :test_template_ref;

	def initialize(name, suite, opts={})
		super(name, suite);
		@name = name;
		@parent = suite;
		@description = "Test case #{name}";
		@parameters = {};
		@test_template_ref = opts[:template] if opts[:template];
		init_parameters_by_template if @test_template_ref;
		suite.register_testcase(self);
	end

	def name
		@name;
	end

	def description(desc = nil)
		@description = desc if desc;
		@description;
	end

	def parameter(name, value = nil, &block)
		name = name.to_s;
		if block_given?
			@parameters[name] = block;
		else
			@parameters[name] = value;
		end
	end

	#not used, def get_parameter(name)
	#not used, 	# First check local parameters, then test template parameters, then parent test parameters
	#not used, 	if @parameters.has_key?(name.to_s)
	#not used, 		param = @parameters[name.to_s];
	#not used, 		if param.is_a?(Proc)
	#not used, 			param.call;
	#not used, 		else
	#not used, 			param;
	#not used, 		end
	#not used, 	elsif @test_template_ref && @parent.has_test_template?(@test_template_ref)
	#not used, 		template = @parent.get_test_template(@test_template_ref);
	#not used, 		template.get_parameter(name);
	#not used, 	else
	#not used, 		@parent.get_parameter(name);
	#not used, 	end
	#not used, end

	def init_parameters_by_template
		template = @parent.get_test_template(@test_template_ref);
		@parameters = template.parameters;
		@config_name = template.config_name;
		@run_args.append(*template.run_args)
	end
	

end



class TestSuite < IpxBaseObject
	attr :description;
	attr_accessor :tests;
	attr_accessor :templates;

	def initialize(vlnv, p)
		super(p);
		@tests = {};
		@templates = {};
		set_vlnv(vlnv.to_s);
	end
	def set_vlnv(vlnv)
		_l=[:vendor,:library,:name,:version];
		parts = vlnv.split('/')
		raise IpxException.new("Invalid VLNV: #{vlnv}") if parts.length != _l.length
		_l.each_with_index do |method_name, index|
			self.define_singleton_method(method_name) do
				parts[index]
			end
		end
		define_singleton_method(:vlnv) do
			parts.join('/')
		end
	end
	def description(desc = nil)
		@description = desc if desc;
		@description;
	end

	def get_test_template(name)
		@templates[name.to_s] || raise(IpxException.new("TestTemplate #{name} not found in suite #{self.name}"));
	end

	def get_testcase(name)
		@tests[name.to_s] || raise(IpxException.new("TestCase #{name} not found in suite #{self.name}"));
	end
	def register_testcase(tc)
		@tests[tc.name] = tc;
	end
	def testcase(name, opts={}, &block)
		name = name.to_s;
		t = TestCase.new(name, self, opts);
		t.instance_eval(&block) if block_given?;
		NodeApp.info("TestCase #{name} registered to suite #{self.name}", 8);
	end
	def template(name, &block)
		name = name.to_s;
		t = TestTemplate.new(name, self);
		t.instance_eval(&block) if block_given?;
		@templates[name] = t;
		NodeApp.info("TestTemplate #{name} registered to suite #{self.name}", 8);
	end
end