# MultJobSystem User Guide

The MultJobSystem is a Ruby module that provides a robust way to manage and execute multiple jobs concurrently while maintaining control over system resources.

## Features

- Concurrent job execution with configurable limits
- Automatic job scheduling and queue management
- Job status tracking
- Debug logging capabilities
- Process management and cleanup

## Basic Usage

### Initialization

```ruby
require_relative 'MultJobSystem'

# Initialize the system with a maximum of 10 concurrent jobs
MultJobSystem.run(10)

# Or set the maximum jobs limit separately
MultJobSystem.max_job = 15
```

### Creating and Submitting Jobs

```ruby
# Create a command (MjsCommand instance)
command = MjsCommand.new(your_command_data)

# Submit the job
process = MultJobSystem.dispatch(command)
```

### Waiting for Jobs

```ruby
# Wait for a specific number of jobs to finish
MultJobSystem.wait_job_finish(2)  # Waits for 2 jobs to complete
```

## Debug Mode

Enable debug logging by setting the environment variable:

```ruby
ENV['DEBUG_MODE'] = 'true'
```

This will provide detailed logging of job operations, including:
- Job submission
- Scheduling decisions
- Job status changes
- Process management

## Job Management

The system automatically:
- Tracks ongoing jobs
- Maintains a list of finished jobs
- Ensures the number of concurrent jobs doesn't exceed the maximum limit
- Handles job completion and cleanup

## Best Practices

1. Always initialize the system with an appropriate job limit based on your system's capabilities
2. Use debug mode during development to monitor job execution
3. Consider system resources when setting the maximum job limit
4. Handle job results appropriately in your application logic

## Example

```ruby
require_relative 'MultJobSystem'
require_relative 'MjsCommand'

# Initialize with 5 concurrent jobs
MultJobSystem.run(5)

# Create and submit multiple jobs
5.times do |i|
  command = MjsCommand.new(:external,self) {"system command"}
  process = MultJobSystem.dispatch(command)
end

# Wait for all jobs to complete
MultJobSystem.wait_job_finish(5)
```

## Notes

- The system automatically manages job scheduling and resource allocation
- Jobs that finish or are killed are automatically moved to the finished jobs list
- The system provides thread-safe operation for concurrent job management
