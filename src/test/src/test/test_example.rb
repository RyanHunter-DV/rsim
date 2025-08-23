# Example usage of the Test class
# This file demonstrates how to create and use Test objects with test templates and test cases

# Load the required modules
require_relative 'init'

# Example 1: Basic Test creation
test1 = Test.new('vendor/library/test_name/1.0', '/path/to/test')

# Set basic properties
test1.description "Basic test specification for demonstration"
test1.test_bench "top_tb"

# Add parameters
test1.parameter 'seed', 12345
test1.parameter 'timeout', 1000000
test1.parameter 'dynamic_value' do
  Time.now.to_i
end

# Add file sets
test1.file_set 'test_files' do
  # FileSet methods would be called here
end

# Example 2: Test with TestTemplate
test2 = Test.new('vendor/library/advanced_test/2.0', '/path/to/advanced_test')

# Create a test template
test2.test_template 'uvm_test_template' do
  description "UVM test template with common parameters"
  test_bench "uvm_tb"
  
  parameter 'uvm_test_name', 'base_test'
  parameter 'uvm_verbosity', 'UVM_MEDIUM'
  parameter 'coverage_enable', true
  
  file_set 'uvm_files' do
    # UVM-specific file set configuration
  end
end

# Create test cases that use the template
test2.test_case 'smoke_test' do
  description "Basic smoke test case"
  test_template 'uvm_test_template'
  
  # Override template parameters
  parameter 'uvm_test_name', 'smoke_test'
  parameter 'timeout', 500000
  
  # Add case-specific file sets
  file_set 'smoke_files' do
    # Smoke test specific files
  end
end

test2.test_case 'regression_test' do
  description "Full regression test case"
  test_template 'uvm_test_template'
  
  # Override template parameters
  parameter 'uvm_test_name', 'regression_test'
  parameter 'uvm_verbosity', 'UVM_HIGH'
  parameter 'timeout', 2000000
  
  # Add case-specific file sets
  file_set 'regression_files' do
    # Regression test specific files
  end
end

# Example 3: Test without template (direct test case definition)
test3 = Test.new('vendor/library/simple_test/1.0', '/path/to/simple_test')

test3.test_case 'direct_test' do
  description "Test case defined directly without template"
  test_bench "simple_tb"
  
  parameter 'test_mode', 'direct'
  parameter 'iterations', 100
  
  file_set 'direct_files' do
    # Direct test files
  end
end

# Example 4: Demonstrating parameter inheritance and lookup
puts "Test 1 parameters: #{test1.parameter_names}"
puts "Test 2 test cases: #{test2.test_case_names}"
puts "Test 2 templates: #{test2.test_template_names}"

# Demonstrate parameter lookup
smoke_test = test2.get_test_case('smoke_test')
puts "Smoke test testbench: #{smoke_test.get_test_bench}"
puts "Smoke test uvm_test_name: #{smoke_test.get_parameter('uvm_test_name')}"
puts "Smoke test uvm_verbosity: #{smoke_test.get_parameter('uvm_verbosity')}"

# Demonstrate template parameter inheritance
regression_test = test2.get_test_case('regression_test')
puts "Regression test testbench: #{regression_test.get_test_bench}"
puts "Regression test uvm_verbosity: #{regression_test.get_parameter('uvm_verbosity')}"
puts "Regression test coverage_enable: #{regression_test.get_parameter('coverage_enable')}"
