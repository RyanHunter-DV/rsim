"""
# Object description:
ComponentView, sub object of a component
"""
class ComponentView < IpxData
	attr :__fs__; # list of file set references
	attr :generator;

	## initialize(name), 
	def initialize(id); ##{{{
		super(:id=>id);
		@__fs__={};
		@generator={};
	end ##}}}


	#### support commands {
	## fileSet(refn), 
	# find fileSet object in container
	def fileSet(refn); ##{{{
		#puts "#{__FILE__}:start fileSet(refn) ..."
		@__fs__[refn.to_s]=nil;
	end ##}}}

	## generator(n,c,**opts), specify generator reference for current view
	# generator reference won't to find the object
	def generator(n,c,**opts) ##{{{
		@generator[:name]=n.to_s;
		@generator[:chain]=c,to_s;
		@generator[:options]=opts;
	end ##}}}
	#}

	## link(t,from), link given typed objects from the given 'from' object
	def link(t,from) ##{{{
		_linkfs(from) if t==:fileSet;
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
	
	## selectGenerator, call the specified chain's select api and setup the generator names and options
	def selectGenerator ##{{{
		cn=@generator[:chain];
		gn=@generator[:name];
		opts=@generator[:options];
		opts[:src] = _sources;
		#opts[:tar] =
		Rsim.ipxact.select(cn,gn,**opts);
	end ##}}}
private
	## _sources, return all source files according to fileSet
	def _sources ##{{{
		srcs=[];
		@__fs__.each_value do |o|
			srcs.append(o.source);
		end
		return srcs;
	end ##}}}
	## _linkfs(from), find object by giving name and replace it
	def _linkfs(from) ##{{{
		@__fs__.each_key do |n|
			o=from.find(:fileSet,n);
			Rsim.exception(:NodeE,:reason=>"fileSet(#{n}) not registered in component(#{from.id})") unless o;
			@__fs__[n]=o;
		end
	end ##}}}
end
