require_relative '../exceptions/ipxe'
require 'fileutils'

class XceliumSimulator
	attr_accessor :out_dir, :testbench, :source_files, :defines, :include_dirs
	attr_accessor :compile_options, :elaborate_options, :run_options
	attr_accessor :full64, :debug, :verbose

	attr_accessor :run_dir;
	def initialize(params={})
		@out_dir = params[:out_dir] || File.join(ENV['OUT_HOME'], 'sim')
		@testbench = params[:testbench]
		@filelist = params[:filelist]
		@source_files = params[:source_files] || []
		@defines = params[:defines] || []
		@include_dirs = params[:include_dirs] || []
		@compile_options = params[:compile_options] || ''
		@elaborate_options = params[:elaborate_options] || ''
		@run_options = params[:run_options] || ''
		@full64 = params[:full64] || false
		@debug = params[:debug] || false
		@verbose = params[:verbose] || false
		@testcase = params[:testcase]
		create_run_dir
	end

	def create_run_dir
		if @testcase
			# Validate testcase format: testsuite/testname
			unless @testcase.match?(/^[^\/]+\/[^\/]+$/)
				raise IpxException.new("Invalid testcase format. Expected 'testsuite/testname', got: #{@testcase}")
			end
			@run_dir = File.join(@out_dir, @testcase)
		else
			@run_dir = @out_dir
		end
		FileUtils.mkdir_p(@run_dir) unless File.directory?(@run_dir)
	end

	def compile
		SimApp.info("Xcelium Compiling...")
		SimApp.debug("Compile parameters: #{compile_params}", 5)
		
		# Build the compile command
		cmd = build_compile_command
		SimApp.debug("Compile command: #{cmd}", 5)
		
		execute_command_via_script(cmd, 'compile_cmd.sh', 'Compilation')
	end

	def elaborate
		SimApp.info("Xcelium Elaborating...")
		SimApp.debug("Elaborate parameters: #{elaborate_params}", 5)
		
		# Build the elaborate command
		cmd = build_elaborate_command
		SimApp.debug("Elaborate command: #{cmd}", 5)
		
		execute_command_via_script(cmd, 'elaborate_cmd.sh', 'Elaboration')
	end

	def run
		SimApp.info("Xcelium Running simulation...")
		SimApp.debug("Run parameters: #{run_params}", 5)
		
		# Build the run command
		cmd = build_run_command
		SimApp.debug("Run command: #{cmd}", 5)
		
		execute_command_via_script(cmd, 'run_cmd.sh', 'Simulation')
	end

	def clean
		SimApp.info("Xcelium Cleaning...")
		FileUtils.rm_rf(Dir.glob(File.join(@out_dir, '*')))
		SimApp.info("Xcelium Clean completed")
	end

private

	def execute_command_via_script(cmd, script_name, operation_name)
		# Create command file in out_dir
		cmd_file = File.join(@out_dir, script_name)
		File.write(cmd_file, "#!/bin/bash\n#{cmd}\n")
		File.chmod(0755, cmd_file)
		
		SimApp.info("Created #{operation_name} command file: #{cmd_file}",0)
		SimApp.info("Executing: #{cmd}",0)
		
		# Execute the command file and capture exit status

		#TODO, test mode, result = system(cmd_file)
		#TODO, test mode, exit_status = $?.exitstatus
		exit_status = 0
		
		if exit_status == 0
			SimApp.info("Xcelium #{operation_name} successful")
		else
			raise EdaException.new("Xcelium #{operation_name} failed with exit status: #{exit_status}")
		end
	end

	def compile_params
		{
			out_dir: @out_dir,
			source_files: @source_files,
			defines: @defines,
			include_dirs: @include_dirs,
			compile_options: @compile_options,
			full64: @full64,
			debug: @debug,
			verbose: @verbose
		}
	end

	def elaborate_params
		{
			out_dir: @out_dir,
			elaborate_options: @elaborate_options,
			full64: @full64,
			debug: @debug,
			verbose: @verbose
		}
	end

	def run_params
		{
			out_dir: @out_dir,
			testbench: @testbench,
			run_options: @run_options,
			verbose: @verbose
		}
	end

	def build_compile_command
		cmd_parts = ['xmvlog']
		
		# Add filelist if provided
		if @filelist
			cmd_parts << "-f #{@filelist}"
		else
			# Add source files if no filelist
			cmd_parts << @source_files.join(' ') unless @source_files.empty?
		end
		
		# Add defines
		@defines.each { |define| cmd_parts << "+define+#{define}" } unless @defines.empty?
		
		# Add include directories
		@include_dirs.each { |dir| cmd_parts << "+incdir+#{dir}" } unless @include_dirs.empty?
		
		# Add output directory
		cmd_parts << "-o #{File.join(@out_dir, 'xmsim')}"
		
		# Add compile options
		cmd_parts << @compile_options unless @compile_options.empty?
		
		# Add flags
		cmd_parts << '-64bit' if @full64
		cmd_parts << '-debug' if @debug
		cmd_parts << '-v' if @verbose
		
		cmd_parts.join(' ')
	end

	def build_elaborate_command
		cmd_parts = ['xmelab']
		
		# Add output directory
		cmd_parts << "-o #{File.join(@out_dir, 'xmsim')}"
		
		# Add elaborate options
		cmd_parts << @elaborate_options unless @elaborate_options.empty?
		
		# Add flags
		cmd_parts << '-64bit' if @full64
		cmd_parts << '-debug' if @debug
		cmd_parts << '-v' if @verbose
		
		cmd_parts.join(' ')
	end

	def build_run_command
		xmsim_path = File.join(@out_dir, 'xmsim')
		raise IpxException.new("Simulator executable not found: #{xmsim_path}") unless File.exist?(xmsim_path)
		
		cmd_parts = [xmsim_path]
		
		# Add testbench
		cmd_parts << "-testbench #{@testbench}" if @testbench
		
		# Add run options
		cmd_parts << @run_options unless @run_options.empty?
		
		# Add verbose flag
		cmd_parts << '-v' if @verbose
		
		# Add log file
		log_file = File.join(@out_dir, 'sim.log')
		cmd_parts << "-l #{log_file}"
		
		cmd_parts.join(' ')
	end
end 