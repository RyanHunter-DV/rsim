# the entry file of link builder for rtl
class Linker
	attr_accessor :app

	def initialize(app)
		@app = app
	end

	def build_file(cpath,file,type,opts)
		
		target_path = File.join(cpath,File.dirname(file))
		target_file = File.join(target_path, File.basename(file))
		source_file = File.absolute_path(File.join(opts[:root],file))
		FileUtils.mkdir_p(target_path) unless File.exist?(target_path)
		
		FileUtils.rm_f(target_file) if File.symlink?(target_file)
		
		app.info("Building file: #{file} in #{target_file}", 5)
		command = "ln -s #{source_file} #{target_file}"
		app.info("[BUILDING COMMAND] #{command}", 5)
		unless system(command)
			raise "Link command failed: #{command}"
		end
		return target_file;
	end
end