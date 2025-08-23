#!/usr/bin/env ruby
# Test script for the simulator framework

# Set up environment variables for testing
ENV['PROJ_HOME'] = File.expand_path('.')
ENV['OUT_HOME'] = File.join(ENV['PROJ_HOME'], 'out')

puts "Testing Simulator Framework"
puts "=========================="
puts "PROJ_HOME: #{ENV['PROJ_HOME']}"
puts "OUT_HOME: #{ENV['OUT_HOME']}"
puts ""

# Test 1: Show help
puts "Test 1: Show help"
puts "Command: ./bins/simulator -h"
puts "---"
system("./bins/simulator -h")
puts ""

# Test 2: Test with invalid flow (should show error)
puts "Test 2: Test with invalid flow"
puts "Command: ./bins/simulator -e invalid_flow"
puts "---"
system("./bins/simulator -e invalid_flow")
puts ""

# Test 3: Test with valid flow but missing PROJ_HOME
puts "Test 3: Test with missing PROJ_HOME"
puts "Command: PROJ_HOME= ./bins/simulator -e vcs_sim"
puts "---"
system("PROJ_HOME= ./bins/simulator -e vcs_sim")
puts ""

# Test 4: Test clean flow
puts "Test 4: Test clean flow"
puts "Command: ./bins/simulator -e vcs_clean_only"
puts "---"
system("./bins/simulator -e vcs_clean_only")
puts ""

puts "Framework test completed!"
puts ""
puts "To run actual VCS simulation, use:"
puts "./bins/simulator -e vcs_sim -p '--testbench tb_top --top-module top_module --source-files design.sv,tb_top.sv'" 