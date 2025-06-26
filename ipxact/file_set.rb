class FileSet < IpxBaseObject
	attr :component;
	attr :root_path;
	attr :sources, :includes;
	def initialize(name,component)
		super(component.node_path);
		@component = component;
		@root_path = @node_path;
		@sources = [];
		@includes = [];
		set_xml_fields(name)
	end

	def set_xml_fields(name)
		self.define_singleton_method(:name) do
			name;
		end
	end

	# support user commands:
	# verilog, specify verilog files, all verilog source files will be built in filelist, unless
	# explicitly specified :filelist=>false.
	def verilog(opts={},*files)
		opts[:type] = :verilog;
		opts[:filelist] = true unless opts.has_key?(:filelist);
		opts[:incdir] = true unless opts.has_key?(:incdir);
		add_source(opts,files);
	end
	def sv(opts={},*files)
		opts[:type] = :sv;
		opts[:filelist] = true unless opts.has_key?(:filelist);
		opts[:incdir] = true unless opts.has_key?(:incdir);
		add_source(opts,files);
	end

	# root, the root path for the files will be collected, by default is the node path.
	def root(path=nil)
		return @root_path if path.nil?;
		unless File.exist?(path)
			raise IpxException.new("Path '#{path}' does not exist")
		end
		@root_path = File.absolute_path(path)
	end

	def finalize
		RsApp.info("Finalizing file set #{self.name}", 8)
	end


private
	def add_source(opts={},*files)
		type = opts[:type];
		@sources[type] = {} unless @sources.has_key?(type);
		files.each do |file|
			@sources[type][file] = opts;
		end
	end
end