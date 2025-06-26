require_relative 'xmls/init'
class MetaDatabase
	attr_accessor :components;
	attr_accessor :configs;
	attr_accessor :design;

	attr :database_dir;
	attr :database_file;

	def initialize(out_home)
		@components = {};
		@design=nil;
		setup_database(out_home);
	end

	def setup_database(out_home)
		@database_dir = File.join(out_home, 'meta')
		FileUtils.mkdir_p(@database_dir)
		@database_file = File.join(@database_dir, 'meta.db')
		FileUtils.touch(@database_file)
	end

	def link_design(c)
		raise IpxException.new("design must declare before link_design") if @design.nil?
		c.design @design;
	end

	# register component need to build a meta database file to record
	# all key messages into the data file.
	def register(type,c)
		NodeApp.debug("[DB_REGISTER] Registering component of type '#{type}'", 9)
		type = type.to_s;
		NodeApp.debug("[DB_TYPE_CONV] Type converted to string: '#{type}'", 9)
		parser_class_name = "#{type.capitalize}Parser"
		NodeApp.debug("[DB_PARSER_LOOKUP] Looking for parser class: '#{parser_class_name}'", 9)
		parser_class = Object.const_get(parser_class_name)
		NodeApp.debug("[DB_PARSER_FOUND] Found parser class: #{parser_class}", 9)
		p = parser_class.new(c, @database_dir)
		NodeApp.debug("[DB_PARSER_INSTANCE] Created parser instance: #{p.class}", 9)
		NodeApp.debug("[DB_DESIGN_CHECK] Current design: #{@design ? @design.class : 'nil'}", 9)
		@design=c if type=='design';
		p.parse_to_xml()
		NodeApp.debug("[DB_PARSE_COMPLETE] Completed parse_to_xml for #{type}", 9)
	end
end