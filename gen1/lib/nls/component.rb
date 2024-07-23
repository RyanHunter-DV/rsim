"""
# Object description:
Component, The IP-XACT component object
"""
require 'lib/nls/IpXactData.rb'
require 'lib/nls/fileSet.rb'
class Component < IpXactData ##{{{

	attr :generator;
	attr :fileSets;

	## initialize(vlnv), description
	def initialize(vlnv); ##{{{
		super(vlnv);
		@generator=nil;
		@fileSets={
			:source=>{}, # store source files
			:target=>{} # for target generated files
		}
	end ##}}}


	## generator(n=nil), 
	# if given n, then specify the generator name, else return the generator name
	def generator(n=nil); ##{{{
		return @generator unless n;
		@generator= n.to_sym;
	end ##}}}

	## fileSet(id,&block), define fines for a certain fileSet
	def fileSet(id,&block); ##{{{
		fs=FileSet.new(id,block.source_location);
		fs.instance_eval block;
		@fileSets[:source][fs.id] = fs;
	end ##}}}
	
end ##}}}

## component(vlnv,&block), 
# declare a component object in user node.
def component(vlnv,&block); ##{{{
	puts "#{__FILE__}:(component(vlnv,&block)) is not ready yet."
	
end ##}}}