class XmlTag
	attr_accessor :name,:parent;
	attr :children;
	attr :single;

	attr :properties;

	# the value of a tag, which can be multiple lines or a string using "\n"
	attr :value_lines;

	def initialize(name, attr={})
		@name = name; # string
		@children = [];
		@parent=nil;
		@single=true;
		@properties = {};
		@value_lines = [];
		filter_implicit_properties(attr);
		@properties.merge!(attr);
	end

	def filter_implicit_properties(attr)
		if attr.has_key?(:parent)
			@parent = attr[:parent].to_s;
		attr.delete(:parent);
		end
		if attr.has_key?(:value)
			@value_lines << attr[:value];
			attr.delete(:value);
		end
	end

	def add_child(child)
		@single=false if @single;
		@children << child
	end

end
class XmlParser
	attr_accessor :parsed_data

	attr :tags
	attr :header_lines;
	attr :root_tag;
	attr :current_indent;

	attr :indent_string;
	def initialize(db_file)
		@db_file = db_file;
		@parsed_data = {}
		@tags={};
		@header_lines = [];
		@root_tag = nil;
		@current_indent = 0;
		@indent_string = "\t";
	end

	def header(line)
		# declare header description content of a xml
		@header_lines << line;
	end

	# tag format:
	# name: tag name
	# single: is a single tag or not, single tag means it has no child tag.
	# by default, a tag been declared is single tag, or else it's been added as a parent of a child tag.
	# attr: :descp=>'xxx',:data=>'xxx'
	def add_tag(name,attr={})
		name = name.to_s;
		tag = XmlTag.new(name,attr)
		@root_tag = tag if tag.parent.nil?;
		NodeApp.debug("Adding tag: #{name}, parent: #{tag.parent}", 9)
		if tag.parent
			parent_tag = @tags[tag.parent]
			if parent_tag.nil?
				raise IpxException.new("Parent tag '#{tag.parent}' not found")
			else
				parent_tag.add_child(tag)
			end
		end
		@tags[name] = tag;
	end

	def indent
		@current_indent += 1;
	end

	def unindent
		@current_indent -= 1;
	end

	def write_to_file
		fh=File.open(@db_file, 'w')
		@header_lines.each do |line|
			fh.write line+"\n"
		end
		fh.write assemble_xml_string(@root_tag)+"\n"
		fh.close
	end

	def xml_string(content)
		(@indent_string * @current_indent) + content
	end
	def assemble_xml_string(tag)
		#tag = @root_tag if tag.nil?
		raise IpxException.new("Tag cannot be nil") if tag.nil?
  
		NodeApp.debug("Assembling XML string for tag: #{tag.name}", 9)
		s= ""
		indent unless tag.parent.nil?;
  
		# Start tag with attributes
		NodeApp.debug("Adding start tag: <#{tag.name}", 9)
		s+=xml_string( %Q|<#{tag.name}|);

		tag.properties.each_pair do |p,v|
			NodeApp.debug("Adding property: #{p}=\"#{tag.properties[p]}\"", 9)
			s+=xml_string %Q| #{p}="#{tag.properties[p]}"|
		end
		only_tag=false;
		only_tag=true if tag.value_lines.empty? and tag.children.empty?
		s+='>' unless only_tag;
		tag.value_lines.each_with_index do |v,i|
			s+= "\n" if i>0
			NodeApp.debug("Adding value line #{i}: #{v}", 9)
			s+= "#{v}"
		end
  
		# Process child tags recursively
		NodeApp.debug("Processing #{tag.children.length} child tags", 9)
		s+="\n" if tag.children.length>0;
		tag.children.each do |child|
			NodeApp.debug("Processing child tag: #{child.name}", 9)
			s+= assemble_xml_string(child)+"\n"
		end
  
		# Close tag
		NodeApp.debug("Adding close tag: </#{tag.name}>", 9)
		if s.end_with?("\n")
			s += xml_string "</#{tag.name}>"
		else
			if only_tag
				s+='/>'
			else
				s += "</#{tag.name}>"
			end
		end
		unindent unless tag.parent.nil?;
  
		NodeApp.debug("Completed XML string assembly for tag: #{tag.name}", 9)
		s
	end
end