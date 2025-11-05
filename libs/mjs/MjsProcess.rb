require_relative 'MjsCommand'
require_relative 'MultJobSystem'
require_relative '../printer'
require 'open3'

class MjsProcess
	attr :job
	attr :job_id
	attr :debug

	# :init, :running, :finished, :killed
	attr :status

	def initialize(job, verbo = 5)
		@job = job
		@status = :init
		@debug = Printer.new(verbo, :severity => :DEBUG)
		@debug > "Initializing MjsProcess with job: #{job.inspect}"
	end

	def record_time(type, time)
		type = type.to_s.upcase + "_TIME"
		@job.record_file.record(type, time)
	end

	def record_output(output)
		@debug > "Recording output: #{output}"
		@job.record_file.record('OUTPUT', output)
	end

	def record_error(error)
		@debug > "Recording error: #{error}"
		@job.record_file.record('ERROR', error)
	end

	def record_status(status)
		@job.record_file.record('STATUS', status.to_s.upcase)
	end

	def record_command(type, command)
		if type == :external
			@job.record_file.record('COMMAND', command)
		else
			@job.record_file.record('COMMAND', command)
		end
	end

	def start
		@debug > "Starting process with status: #{@status}"
		@status = :running
		job = @job
		pid = fork do
			@debug > "Forked process with PID: #{Process.pid}"
			job.record_file(Process.pid.to_s)
			record_status(:running)
			record_command(job.type, job.exec)
			if job.type == :external
				@debug > "(#{Process.pid}) Executing external job: #{job.exec}"
				record_time(:start, Time.now.strftime("%Y-%m-%d %H:%M:%S"))
				stdout, stderr, status = Open3.capture3(job.exec)
				if status.exitstatus != 0
					@status = :finished_on_error
				else
					@status = :finished_on_success
				end
				record_time(:finish, Time.now.strftime("%Y-%m-%d %H:%M:%S"))
				job.record_file.logging_output(stdout, stderr)
			else
				@debug > "Executing internal job: #{job.exec}"
				record_time(:start, Time.now.strftime("%Y-%m-%d %H:%M:%S"))
				@debug.write("Executing internal job in context: #{job.context.inspect}",0)
				result=job.context.instance_eval(&job.exec)
				#TODO, currently return with finished_on_success only, the return value of instance_eval
				#based on last code line.
				if result!=0
					record_error(result.to_s)
					@status=:finished_on_error
				else
					@status=:finished_on_success
				end
				record_time(:finish, Time.now.strftime("%Y-%m-%d %H:%M:%S"))
			end
			process_on_finish
			@debug > "Process completed, exiting, job status: #{@status}"
			exit!
		end
		@job_id = pid
		Process.detach(pid)
		@debug > "Process detached with job_id: #{@job_id}"
		@debug > "Process finished, pid: #{pid}"
	end

	def detect_finished_status(first_line)
		ptrn = Regexp.new('RECORD_DATA-STATUS: (FINISHED_\w+)')
		if ptrn =~ first_line
			return $1.downcase.to_sym
		end
		return nil
	end

	def detect_killed_status(first_line)
		ptrn = Regexp.new('RECORD_DATA-STATUS: KILLED')
		if ptrn =~ first_line
			return :killed
		end
		return nil
	end

	def wait_process_done(wait_time=0)
		log_path = MultJobSystem.log_path
		record_file_path = File.join(log_path, "record_data-#{@job_id}.txt")
		first_line = `head -n 1 "#{record_file_path}"`.strip
		status = detect_finished_status(first_line)
		if status != nil
			puts "detecting finished status for job_id: #{@job_id}, update self.status to :finished"
			@status = status
		elsif detect_killed_status(first_line)
			puts "detecting killed status for job_id: #{@job_id}, update self.status to :killed"
			@status = :killed
		else
			puts "detecting unknown status for job_id: #{@job_id}, waiting status completed" if wait_time == 0
			sleep(5)
			return wait_process_done(wait_time+1)
		end
	end

	def get_status
		log_path = MultJobSystem.log_path
		record_file_path = File.join(log_path, "record_data-#{@job_id}.txt")
		first_line = `head -n 1 "#{record_file_path}"`.strip
		status = detect_finished_status(first_line)
		if status != nil
			@status = status
		end
		status = detect_killed_status(first_line)
		if status != nil
			@status = status
		end
		return @status
	end

	def await
		puts("Awaiting process with pid: #{@job_id} at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}")
		puts("status of job_id: #{@job_id} is #{@status}")
		if @status.to_s !~ /finished/i && @status.to_s !~ /killed/i
			wait_process_done
		end
		puts("Process with pid: #{@job_id} finished at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}, status: #{@status}")
		@status
	end

	private

	def process_on_finish
		@debug > "Sub process on finish, pid: #{Process.pid}"
		record_status(@status)
		@job.record_file.close
	end
end