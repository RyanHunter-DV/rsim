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
	def read_from_file
		xml_data = File.read(@db_file)
		xml_data
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
		if tag.parent.nil?
			s+=xml_string( %Q|<root:#{tag.name}|);
		else
			s+=xml_string( %Q|<#{tag.name}|);
		end
		NodeApp.debug("Adding start tag: <#{tag.name}", 9)

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
	def extract_value(xml_content, tag_name, match_once=true)
		results = []
		pos = 0
		
		while pos < xml_content.length
			# Find the next opening tag (including any attributes)
			start_pos = xml_content.index(/<#{tag_name}(?:\s+[^>]*)?>/, pos)
			break if start_pos.nil?
			
			# Find the position after the opening tag
			opening_tag_end = xml_content.index('>', start_pos) + 1
			
			# Count opening and closing tags to find the matching closing tag
			depth = 1
			search_pos = opening_tag_end
			
			while depth > 0 && search_pos < xml_content.length
				next_open = xml_content.index(/<#{tag_name}(?:\s+[^>]*)?>/, search_pos)
				next_close = xml_content.index("</#{tag_name}>", search_pos)
				
				if next_open && next_close && next_open < next_close
					depth += 1
					search_pos = next_open + 1
				elsif next_close
					depth -= 1
					search_pos = next_close + 1
				else
					break
				end
			end
			
			if depth == 0
				# Found the matching closing tag
				end_pos = xml_content.rindex("</#{tag_name}>", search_pos - 1)
				content = xml_content[opening_tag_end...end_pos]
				results << content.strip
				
				# If match_once is true, break after first match
				break if match_once
				
				pos = end_pos + "</#{tag_name}>".length
			else
				# No matching closing tag found, move to next position
				pos = start_pos + 1
			end
		end
		
		raise IpxException.new("extract_value: #{tag_name} not found in xml_content") if results.empty?
		
		# Return string if match_once is true, array if match_once is false
		return match_once ? results[0] : results
	end

	def extract_section(xml_content, section_name, match_once=true)
		results = []
		pos = 0
		
		while pos < xml_content.length
			# Find the next opening tag (including any attributes)
			start_pos = xml_content.index(/<#{section_name}(?:\s+[^>]*)?>/, pos)
			break if start_pos.nil?
			
			# Find the position after the opening tag
			opening_tag_end = xml_content.index('>', start_pos) + 1
			
			# Count opening and closing tags to find the matching closing tag
			depth = 1
			search_pos = opening_tag_end
			
			while depth > 0 && search_pos < xml_content.length
				next_open = xml_content.index(/<#{section_name}(?:\s+[^>]*)?>/, search_pos)
				next_close = xml_content.index("</#{section_name}>", search_pos)
				
				if next_open && next_close && next_open < next_close
					depth += 1
					search_pos = next_open + 1
				elsif next_close
					depth -= 1
					search_pos = next_close + 1
				else
					break
				end
			end
			
			if depth == 0
				# Found the matching closing tag
				end_pos = xml_content.rindex("</#{section_name}>", search_pos - 1)
				# Include the complete tag pair (opening tag + content + closing tag)
				content = xml_content[start_pos...(end_pos + "</#{section_name}>".length)]
				results << content
				
				# If match_once is true, break after first match
				break if match_once
				
				pos = end_pos + "</#{section_name}>".length
			else
				# No matching closing tag found, move to next position
				pos = start_pos + 1
			end
		end
		
		raise IpxException.new("extract_section: #{section_name} not found in xml_content") if results.empty?
		
		# Return string if match_once is true, array if match_once is false
		return match_once ? results[0] : results
	end
	def extract_vlnv(xml_data)
		vendor=extract_value(xml_data, 'vendor')
		library=extract_value(xml_data, 'library')
		name=extract_value(xml_data, 'name')
		version=extract_value(xml_data, 'version')
		return "#{vendor}/#{library}/#{name}/#{version}"
	end
end