require 'fileutils'

class CmdRecord
	attr_accessor :record_file;
	attr_accessor :log_file;

	attr :record_format;
	def initialize(id, log_path='.')
		file_prefix="record_data-";
		file_name = File.join(log_path, file_prefix+id+".txt")
		log_file_name = File.join(log_path, 'process-'+id+".log")
		
		# Ensure the directory exists
		FileUtils.mkdir_p(log_path) unless Dir.exist?(log_path)
		
		File.delete(file_name) if File.exist?(file_name)
		@record_file = File.open(file_name,"w");
		if File.exist?(log_file_name)
			File.rename(log_file_name, log_file_name + ".bak")
		end
		@log_file = File.open(log_file_name,"w");
		@record_format = {};
	end
	def record_format(type,line)
		# set type with certain line, record type will be:
		# RECORD_DATA-TYPE: CONTENT
		# and the line gives which line will this content exists.
		@record_format[type] = line;
	end
	def logging_output(stdout,stderr)
		@log_file.write(stdout) if stdout
		@log_file.write(stderr) if stderr
		@log_file.flush
	end

	def record(type, content)
		line_number = @record_format[type]
		if line_number.nil?
			raise "Record format not set for type: #{type}"
		end
		
		# Read all lines from the file
		lines = File.readlines(@record_file.path)
		
		# Ensure the array is large enough
		while lines.length < line_number
			lines << "\n"
		end
		
		# Insert the content at the specified line
		lines[line_number - 1] = "RECORD_DATA-#{type}: #{content}\n"
		
		# Write back to the file
		@record_file.rewind
		@record_file.write(lines.join)
		@record_file.flush
	end

	def close
		@record_file.close
		@log_file.close
	end
end