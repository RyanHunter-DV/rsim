"""
# Object description:
ComponentView, sub object of a component
"""
class ComponentView < IpxData ##{{{
	attr :files; # list of file set references
	## initialize(name), 
	def initialize(id); ##{{{
		#puts "#{__FILE__}:start initialize(name) ..."
		super(:id=>id);
		@files=[];
	end ##}}}

	# support commands
	## fileSet(refn), 
	# find fileSet object in container
	def fileSet(refn); ##{{{
		#puts "#{__FILE__}:start fileSet(refn) ..."
		@files << refn;
	end ##}}}

	## display, 
	# print internal data formats of view component
	def display; ##{{{
		#puts "#{__FILE__}:start display ..."
		puts "type: ComponentView";
		puts "- id: #{id}";
		puts "- fileSets-> Array"
		puts "["
		@files.each do |f|
			puts "-- #{f}";
		end
		puts "]"
	end ##}}}
	
end ##}}}