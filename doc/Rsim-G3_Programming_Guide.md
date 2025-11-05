# Rsim-G3 Programming Guide

## Overview

Rsim-G3 is a Ruby-based simulation and build management framework designed for hardware design and verification. The system provides a modular architecture for managing IP-XACT components, building designs, running simulations, and orchestrating complex workflows.

## Architecture

### Core Components

The system is built around four main application types:

1. **BuildApp** - Component building and compilation
2. **NodeApp** - Node loading and management
3. **SimApp** - Simulation execution and management
4. **RsApp** - General workflow and chain execution

### Directory Structure

```
├── bins/          # Executable entry points
src/
├── app/           # Main application classes
├── builders/      # Build and simulation engines
├── chains/        # Workflow definitions
├── exceptions/    # Custom exception classes
├── ipxact/        # IP-XACT data model and parsers
├── loaders/       # Data loading mechanisms
├── plugin/        # Plugin system
├── ui/            # User interface components
└── test/          # Test files and examples
```

## Application Architecture

### Base Application Pattern

All applications follow a similar pattern:

```ruby
class Application
  attr_accessor :ui, :meta
  
  def initialize
    # Initialize UI
    @ui = SpecificUi.new()
    
    # Setup logging and verbosity
    AppClass.info("setting verbosity overrides")
    AppClass.printer.set_verbosity(@ui.verbosity(:info))
    AppClass.debugger.set_verbosity(@ui.verbosity(:debug))
    AppClass.debugger.enable(@ui.options[:debug_mode])
    
    # Initialize metadata database
    @meta = MetaDatabase.new(@ui.options[:out_home], AppClass)
    
    # Application-specific initialization
    # ...
  end
  
  def run
    # Main execution logic
    # ...
  end
end

module AppClass extend ReportApi
  @@app = nil
  
  def self.init
    @@app = Application.new
  end
  
  def self.run
    @@app.run
  end
end
```

### ReportApi Mixin

All applications include the `ReportApi` module for consistent logging:

```ruby
module ReportApi
  def debug(message, verbo=5)
    if @debugger.nil?
      puts "[RAW] #{message}"
    else
      @debugger.write(message, verbo, 1)
    end
  end
  
  def info(message, verbo=5)
    if @printer.nil?
      puts "[RAW] #{message}"
    else
      @printer.write(message, verbo, 1)
    end
  end
  
  def debugger
    @debugger ||= Printer.new(10, :D)
  end
  
  def printer
    @printer ||= Printer.new(10, :I)
  end
end
```

## IP-XACT Data Model

### Core Classes

The system implements a simplified IP-XACT data model:

- **IpxBaseObject** - Base class for all IP-XACT objects
- **Component** - Represents hardware components
- **Config** - Configuration objects
- **Design** - Design top-level objects
- **View** - Component views
- **FileSet** - File collections

### MetaDatabase

The `MetaDatabase` class manages all IP-XACT objects:

```ruby
class MetaDatabase
  attr_accessor :components, :configs, :design
  
  def initialize(out_home, app)
    @app = app
    @components = {}
    @configs = {}
    @design = nil
    setup_database(out_home)
  end
  
  def register(type, c)
    # Parse and store objects by type
    parser_class_name = "#{type.capitalize}Parser"
    parser_class = Object.const_get(parser_class_name)
    p = parser_class.new(c, @database_dir, @app)
    p.parse_to_xml()
  end
  
  def find(type, name=nil, opts={})
    message = "find_#{type}"
    self.send(message, name, opts)
  end
end
```

## Build System

### Builder Architecture

The build system uses a factory pattern:

```ruby
class Builder
  attr_accessor :app, :exe, :build_home
  
  def initialize(ui, app)
    @app = app
    # Dynamically instantiate builder based on method
    method_class = ui.options[:method].to_s.capitalize + 'er'
    @exe = Object.const_get(method_class).new(app)
    @build_home = File.join(ui.out_home, 'build')
    setup_build_home
  end
  
  def build_component(c, view_name)
    component_dir_name = c.name + '-' + view_name
    cpath = File.join(@component_home, component_dir_name)
    create_dir(cpath)
    
    c.file_sets.each do |name, o|
      o.sources.each do |type, files|
        files.each do |file, opts|
          @exe.build_file(cpath, file, type, opts)
        end
      end
    end
  end
end
```

### VCS Simulator

The VCS simulator provides a complete simulation flow:

```ruby
class VcsSimulator
  def initialize(params={})
    @out_dir = params[:out_dir] || File.join(ENV['OUT_HOME'], 'sim')
    @filelist = params[:filelist]
    @compile_options = params[:compile_options] || ''
    @elaborate_options = params[:elaborate_options] || ''
    @run_options = params[:run_options] || ''
    @full64 = params[:full64] || false
    @debug = params[:debug] || false
    @verbose = params[:verbose] || false
    @testcase = params[:testcase]
    create_run_dir
  end
  
  def compile
    cmd = build_compile_command
    execute_command_via_script(cmd, 'compile_cmd.sh', 'Compilation')
  end
  
  def elaborate
    cmd = build_elaborate_command
    execute_command_via_script(cmd, 'elaborate_cmd.sh', 'Elaboration')
  end
  
  def run
    cmd = build_run_command
    execute_command_via_script(cmd, 'run_cmd.sh', 'Simulation')
  end
end
```

## Generator System

### Generator Definition

Generators are defined using a DSL:

```ruby
generator :vcs_compile do
  exe "vcs"
  arg :filelist, :value => '-f ${filelist}', :required => true
  arg :top_module, :value => '-top ${top_module}', :required => false
  arg :defines, :value => '+define+${defines}', :required => false
  arg :include_dirs, :value => '+incdir+${include_dirs}', :required => false
  arg :out_dir, :value => '-o ${out_dir}/simv', :required => false
  arg :compile_options, :value => '${compile_options}', :required => false
  arg :full64, :value => '-full64', :required => false
  arg :debug, :value => '-debug_all', :required => false
  arg :verbose, :value => '-v', :required => false
  phase 0
end
```

### Generator Chain

Chains orchestrate multiple generators:

```ruby
chain :vcs_sim do
  generator :vcs_compile do
    param '--source_files' => ENV['SOURCE_FILES'] || '*.sv'
    param '--top_module' => @params['-top']
    param '--include_dirs' => ENV['INCLUDE_DIRS'] || ''
    param '--out_dir' => File.join(ENV['OUT_HOME'], 'sim')
    param '--compile_options' => ENV['COMPILE_OPTIONS'] || ''
    param '--full64' => ENV['FULL64'] || false
    param '--debug' => ENV['DEBUG'] || false
    param '--verbose' => ENV['VERBOSE'] || false
  end
  
  generator :vcs_elaborate do
    param '--top_module' => @params['-top']
    param '--out_dir' => File.join(ENV['OUT_HOME'], 'sim')
    param '--elaborate_options' => ENV['ELABORATE_OPTIONS'] || ''
    param '--full64' => ENV['FULL64'] || false
    param '--debug' => ENV['DEBUG'] || false
    param '--verbose' => ENV['VERBOSE'] || false
  end
  
  generator :vcs_run do
    param '--testbench' => ENV['TESTBENCH'] || ''
    param '--run_options' => ENV['RUN_OPTIONS'] || ''
    param '--verbose' => ENV['VERBOSE'] || false
    param '--log_file' => File.join(ENV['OUT_HOME'], 'sim', 'sim.log')
  end
end
```

### Chain Execution

Chains execute generators in phases:

```ruby
def execute(params)
  select_gens = traverse_chain()
  
  # Group generators by phase and execute in order
  phases = select_gens.values.group_by(&:phase).keys.sort
  
  phases.each do |phase|
    phase_gens = select_gens.values.select { |gen| gen.phase == phase }
    
    # Execute all generators in the same phase in parallel
    processes = []
    phase_gens.each do |gen|
      p = params.merge(gen.params)
      processes << gen.execute(p)
    end
    
    # Wait for all jobs in this phase to complete
    status = RsApp.mj.await(processes)
    
    # Check for failures
    failed_jobs = status.select { |job_id, job_status| job_status == :finished_on_error }
    if failed_jobs.any?
      raise Exception, "One or more generators in phase #{phase} failed with error"
    end
  end
end
```

## User Interface

### Base UI Class

All UI classes inherit common functionality:

```ruby
class UI
  attr :options, :proj_home, :flow_command, :chain, :log_path
  
  def initialize
    @verbosity = { :info => 5, :debug => 10 }
    env_setup
    
    @options = {
      :max_jobs => 10,
      :debug_mode => false,
      :log_file => File.join(@proj_home, 'rsim.log'),
      :debug_log_file => File.join(@proj_home, 'rsim_debug.log'),
      :out_home => File.absolute_path(File.join(@proj_home, 'out'))
    }
    
    @chain = { :name => nil, :skip => [], :params => {} }
    setup_options
    @log_path = File.join(@options[:out_home], 'logs')
  end
  
  def env_setup
    @proj_home = ENV['PROJ_HOME']
    raise UIException.new("ENV 'PROJ_HOME' required and not set") if @proj_home.nil? || @proj_home.empty?
  end
end
```

### Command Line Parsing

The UI system uses OptionParser for command line arguments:

```ruby
def setup_options
  OptionParser.new do |opts|
    opts.banner = "Usage: rsim [options]"
    
    opts.on("-v", "--verbose LEVEL", Integer, "Set verbose level (0-10)") do |level|
      @verbosity[:info] = level
    end
    
    opts.on("-d", "--debug [LEVEL]", Integer, "Set debug level (0-10)") do |level|
      @verbosity[:debug] = level || 10
      @options[:debug_mode] = true
    end
    
    opts.on("-e", "--flow COMMAND", String, "Execute a flow command") do |command|
      @flow_command = command
      raise UIException.new("Flow command cannot be empty") if command == ''
    end
    
    opts.on("-p", "--param PARAMS", String, "Add parameters to chain command") do |params|
      if params.include?('=')
        name, value = params.split('=', 2)
        @chain[:params][name.strip.to_s] = value.strip
      else
        name, value = params.split(' ')
        @chain[:params][name.strip.to_s] = value.strip
      end
    end
  end.parse!
end
```

## Plugin System

### RsAction

The plugin system uses actions for extensibility:

```ruby
class RsAction
  attr :step_name, :phase, :command, :action_name, :container
  
  def initialize(action_name, step_name, container)
    @action_name = action_name
    @step_name = step_name || 'default_step'
    @phase = 0
    @command = { :type => nil, :cmd => nil, :context => nil }
    @container = container
  end
  
  def phase(number=nil)
    return @phase if number.nil?
    @phase = number
  end
  
  def command(type, context, &block)
    @command[:type] = type.to_sym
    if @command[:type] == :external
      @command[:cmd] = self.instance_eval(&block)
    elsif @command[:type] == :internal
      @command[:context] = context
      @command[:cmd] = lambda do |*args|
        begin
          block.call
          0
        rescue Exception => e
          "Error in internal command: #{e.message}"
        end
      end
    end
  end
  
  def job
    MjsCommand.new(@command[:type], @command[:context], @command[:cmd])
  end
end
```

## Exception Handling

### Custom Exceptions

The system defines several custom exception types:

```ruby
class UIException < Exception
  def initialize(message)
    super(message)
  end
end

class IpxException < Exception
  attr_accessor :level, :message
  
  def initialize(message, level=0)
    @message = message
    @level = level
  end
end

class EdaException < Exception
  attr_accessor :level, :message
  
  def initialize(message, level=0)
    @message = message
    @level = level
  end
end
```

## Usage Examples

### Running a Simulation

```bash
# Set required environment variables
export PROJ_HOME=/path/to/project
export OUT_HOME=/path/to/output

# Run VCS simulation
./bins/simulator -e simflow -p '--simulator vcs --filelist filelist.f --testcase testsuite/test1'

# Run with custom options
./bins/simulator -e simflow -p '--simulator vcs --filelist filelist.f --testcase testsuite/test1 --vcs_comp_options "-full64 -debug_all"'
```

### Building Components

```bash
# Set environment
export PROJ_HOME=/path/to/project
export OUT_HOME=/path/to/output

# Build components
./bins/builder --config config_name --method vcs
```

### Running Workflows

```bash
# Set environment
export PROJ_HOME=/path/to/project
export OUT_HOME=/path/to/output

# Execute a workflow chain
./bins/rsim -e buildflow -p '--config config_name'

# Execute simulation flow
./bins/rsim -e simflow -p '--eda vcs --config config_name'
```

## Development Guidelines

### Adding New Generators

1. Define the generator in a chain file:
```ruby
generator :my_generator do
  exe "my_tool"
  arg :input, :value => '${input}', :required => true
  arg :output, :value => '${output}', :required => true
  phase 1
end
```

2. Register the generator in the application:
```ruby
RsApp.register_generator(MyGenerator.new)
```

### Adding New Simulators

1. Create a simulator class inheriting from a base class:
```ruby
class MySimulator < BaseSimulator
  def initialize(params={})
    super(params)
    # Custom initialization
  end
  
  def compile
    # Custom compilation logic
  end
  
  def run
    # Custom run logic
  end
end
```

2. Register the simulator in SimApp:
```ruby
def execute_simulation(params)
  case params[:simulator].downcase
  when 'my_sim'
    execute_my_simulation(params)
  # ... other cases
  end
end
```

### Error Handling

Always use the custom exception classes and provide meaningful error messages:

```ruby
def validate_input(input)
  unless input && File.exist?(input)
    raise UIException.new("Input file '#{input}' does not exist")
  end
end

def execute_command(cmd)
  result = system(cmd)
  unless result
    raise EdaException.new("Command failed: #{cmd}")
  end
end
```

### Logging

Use the built-in logging system with appropriate verbosity levels:

```ruby
# Info messages (default verbosity)
RsApp.info("Processing component: #{component.name}", 5)

# Debug messages (higher verbosity)
RsApp.debug("Component details: #{component.inspect}", 8)

# Error conditions
RsApp.info("Warning: Parameter not found", 3)
```

## Testing

The system includes a test framework in the `test/` directory. Tests can be run using:

```bash
cd test
./setup.sh
ruby test_simulator.rb
```

## Conclusion

Rsim-G3 provides a robust framework for hardware design and simulation management. The modular architecture makes it easy to extend with new tools, simulators, and workflows. The IP-XACT integration ensures compatibility with industry standards, while the generator system provides flexibility for complex build and simulation flows.

For more detailed information about specific components, refer to the individual source files and the existing documentation in the `doc/` directory.
