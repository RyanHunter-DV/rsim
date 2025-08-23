class Builder

	attr_accessor :app;
	attr :exe;
	attr :build_home;
	attr :file_lists;
	attr :config_home;
	def initialize(ui,app)
		@app = app;
		method_class = ui.options[:method].to_s.capitalize+'er';
		@exe = Object.const_get(method_class).new(app)
		@build_home = File.join(ui.out_home,'build');
		@component_home = File.join(@build_home,'components');
		@config_home = File.join(@build_home,'configs');
		@file_lists = {:incdir=>[],:source=>[]};
		setup_build_home;
	end

	require 'fileutils';
	def setup_build_home
		create_dir(@build_home)
		create_dir(@component_home)
		create_dir(@config_home)
	end
	def create_dir(path)
		FileUtils.mkdir_p(path) unless Dir.exist?(path)
	end

	def build_component(c,view_name)
		component_dir_name=c.name+'-'+view_name;
		cpath = File.join(@component_home,component_dir_name);
		create_dir(cpath)
		app.info("Building component: #{c.name} in view: #{view_name}", 5)
		app.debug("Component path: #{cpath}", 5)

		c.file_sets.each do |name,o|
			app.info("Building file set: #{name}", 5)
			app.debug("File set sources: #{o.sources}", 5)
			o.sources.each do |type,files|
				app.debug("File set sources: #{type}}", 5)
				files.each do |file,opts|
					app.debug("File set source: #{file}->#{opts.inspect}", 5)
					@file_lists[:source] << @exe.build_file(cpath,file,type,opts);
				end
			end
			o.includes.each do |path|
				@file_lists[:incdir] << path
			end
		end
	end
	def build_filelist(cpath)
		app.info("Building file list: #{cpath}", 5)
		app.debug("File list: #{@file_lists}", 5)
		File.open(File.join(cpath,'filelist.f'),'w') do |f|
			@file_lists[:incdir].each do |file|
				# file list need to be refined by simulator
				f.puts "${incdir}=#{file}"
			end
			@file_lists[:source].each do |file|
				f.puts file
			end
		end
	end

	def build_config(config)
		app.info("Building config: #{config.name}", 5)
		app.debug("Config: #{config.inspect}", 5)
		config_dir_name=config.name;
		cpath = File.join(@config_home,config_dir_name);
		create_dir(cpath)
		build_filelist(cpath)
	end
end