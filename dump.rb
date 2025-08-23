#! /usr/bin/env ruby

def main
	# Get the zip file path from user input
	base_path='/mnt/upload/upload/ryan.huang/';
	print "Enter the path to the zip file: "
	src = File.join(base_path,gets.chomp.strip)
	
	# Validate that the file exists
	unless File.exist?(src)
		puts "Error: File '#{src}' does not exist"
		return
	end
	
	# Extract the filename from the path
	zip_filename = File.basename(src)
	
	# Copy file from src to current directory
	system("cp #{src} .")

	# Unzip the file
	system("unzip #{zip_filename}")

	# Extract the directory name from the zip file (remove .zip extension)
	extracted_dir = zip_filename.sub(/\.zip$/, '')

	# Move contents from extracted directory to current directory
	# Find all files in extracted directory and copy them preserving directory structure
	# Use find command to get all files, then process each one
	require 'fileutils'
	use_p4 = false;
	#print "Use P4? (y/n) [y]: "
	#input = gets.chomp.downcase
	#use_p4 = input.empty? || input == 'y'
	IO.popen("find #{extracted_dir} -type f") do |io|
		io.each_line do |line|
			next if line.include?('doc')
			call_add=false;
			file = line.chomp
			target_path = file.sub(/^#{extracted_dir}\//, '')
			puts "processing file from #{file} to #{target_path}";
			if use_p4 
				if File.exists?(target_path);
					system("p4 edit #{target_path}") 
				else
					call_add = true;
				end
			end
			FileUtils.mkdir_p(File.dirname(target_path))
			system("cp -f #{file} #{target_path} -S .bak")
			system("p4 add #{target_path}") if call_add;
		end
	end

	# Clean up - remove the zip file and empty extracted directory
	system("rm -f #{zip_filename}")
	system("rm -rf #{extracted_dir}")



end
main;