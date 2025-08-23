require_relative '../exceptions/ipxe'
require 'fileutils'

class VcsSimulator
	attr_accessor :remote, :out_dir, :filelist, :compile_options, :elaborate_options, :run_options
	attr_accessor :full64, :debug, :verbose, :run_dir;

	def initialize(params={})
		@remote = params[:remote];
		@out_dir = params[:out_dir];
		@filelist = params[:filelist];
		@compile_options = params[:compile_options];
		@elaborate_options = params[:elaborate_options];
		@run_options = params[:run_options];
		@full64 = params[:full64];
		@debug = params[:debug];
		@verbose = params[:verbose];
		@run_dir = params[:run_dir];
	end

	def create_run_dir
		FileUtils.mkdir_p(@run_dir) unless File.directory?(@run_dir)
	end

	def pre_process_compile
		SimApp.info("VCS Pre-processing compile...")
		SimApp.debug("Pre-process compile parameters: #{compile_params}", 5)

		if File.exist?(@filelist)
			content = File.read(@filelist)
			updated_content = content.gsub(/^\s*\$\{incdir\}=(.*)$/) { "+incdir+#{$1.strip}" }
			File.write(@filelist, updated_content)
			SimApp.debug("Updated filelist #{@filelist}: replaced '${incdir}=' with '+incdir+'", 6)
		else
			SimApp.info("Filelist #{@filelist} does not exist, skipping incdir replacement", 6)
		end

		SimApp.info("VCS Pre-process compile completed")
	end

	def compile
		SimApp.info("VCS Compiling...")
		SimApp.debug("Compile parameters: #{compile_params}", 5)
		
		pre_process_compile;
		# Build the compile command
		cmd = build_compile_command
		SimApp.debug("Compile command: #{cmd}", 5)
		
		execute_command_via_script(cmd, 'compile_cmd.sh', 'Compilation', @out_dir)
	end

	def elaborate
		SimApp.info("VCS Elaborating...")
		SimApp.debug("Elaborate parameters: #{elaborate_params}", 5)
		
		# Build the elaborate command
		cmd = build_elaborate_command
		SimApp.debug("Elaborate command: #{cmd}", 5)
		
		execute_command_via_script(cmd, 'elaborate_cmd.sh', 'Elaboration', @out_dir)
	end

	def run
		SimApp.info("VCS Running simulation...")
		SimApp.debug("Run parameters: #{run_params}", 5)

		create_run_dir
		cmd = build_run_command
		SimApp.debug("Run command: #{cmd}", 5)
		
		system(%Q|chmod u+x #{File.join(@out_dir, 'simv')}|);
		execute_command_via_script(cmd, 'run_cmd.sh', 'Simulation', @run_dir)
	end

	def clean
		SimApp.info("VCS Cleaning...")
		FileUtils.rm_rf(Dir.glob(File.join(@out_dir, '*')))
		SimApp.info("VCS Clean completed")
	end

private

	def execute_command_via_script(cmd, script_name, operation_name, out_path)
		# Create command file in out_dir
		cmd_file = File.join(out_path, script_name)
		remote_cmd = @remote ? 'bsub -Is -q dv' : '';
		File.write(cmd_file, "#!/bin/bash\ncd #{out_path}; #{remote_cmd} #{cmd}\n")
		File.chmod(0755, cmd_file)
		
		SimApp.info("Created #{operation_name} command file: #{cmd_file}",0)
		SimApp.info("Executing: #{cmd}",0)
		
		# Execute the command file and capture exit status
		#result = system(%Q|cd #{out_path};#{cmd_file}|)
		result = system(cmd_file)
		exit_status = $?.exitstatus
		
		if exit_status == 0
			SimApp.info("VCS #{operation_name} successful")
		else
			raise EdaException.new("VCS #{operation_name} failed with exit status: #{exit_status}")
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
		cmd_parts = ['vlogan']
		
		cmd_parts << '-full64' if @full64
		cmd_parts << '-sverilog -kdb'
		# no need, cmd_parts << "-o #{File.join(@run_dir, 'simv')}"
		cmd_parts << @compile_options unless @compile_options.empty?
		cmd_parts << '-debug_access+all'
		cmd_parts << '-l vcs_compile.log';
		cmd_parts << "-f #{@filelist}"
		cmd_parts << '-incr_vlogan'
		
		cmd_parts.join(' ')
	end

	def build_elaborate_command
		cmd_parts = ['vcs']
		
		cmd_parts << @elaborate_options unless @elaborate_options.empty?
		cmd_parts << '-full64' if @full64
		cmd_parts << '-debug_access+all'
		cmd_parts << '-sverilog'
		cmd_parts << '+fsdb+force'
		cmd_parts << '-l vcs_elaborate.log';
		cmd_parts << '-kdb';
		cmd_parts << '-Mupdate=1'; ## incremental compilation
		
		cmd_parts.join(' ')
	end

	def build_run_command
		simv_path = File.join(@out_dir, 'simv')
		raise IpxException.new("Simulator executable not found: #{simv_path}") unless File.exist?(simv_path)
		
		cmd_parts = [];
		#TODO, not required, cmd_parts << %Q|cd #{@run_dir};|
		cmd_parts << simv_path;
		cmd_parts << @run_options unless @run_options.empty?
		cmd_parts << '-l sim.log'
		
		cmd_parts.join(' ')
	end
end