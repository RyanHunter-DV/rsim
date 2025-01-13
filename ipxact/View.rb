"""
# Object description:
ComponentView, sub object of a component
"""
class ComponentView < IpxData
	attr :__fs__; # list of file set references
	attr :generator;

	attr :container;
	## initialize(name), 
	def initialize(id,from); ##{{{
		super(:id=>id,:ipxact=>:view);
		@__fs__={};
		@container=from;
	end ##}}}

	## container(c), change container
	def container(c) ##{{{
		@container=c;
	end ##}}}

	#### support commands {
	## fileSet(refn), 
	# find fileSet object in container
	def fileSet(refn); ##{{{
		@__fs__[refn.to_s]=nil;
		@metadata.add(:fileSet,refn.to_s);
	end ##}}}

	## generator(n,c,**opts), specify generator reference for current view
	# generator reference won't to find the object
	def generator(n,c,**opts) ##{{{
		@generator={};
		@generator[:name]=n.to_s;
		@generator[:chain]=c.to_s;
		@generator[:options]=opts;
		@metadata.record(:generator,@generator);
	end ##}}}
	#}

	## link(t,from), link given typed objects from the given 'from' object
	def link(t,from) ##{{{
		_linkfs(from) if t==:fileSet;
	end ##}}}

	## metadata(t=:ruby), call metadata directly will return the data information to be recorded
	# by default use ruby type.
	def metadata(t=:ruby) ##{{{
		@metadata.dataString(t);
	end ##}}}
	
	## selectGenerator, call the specified chain's select api and setup the generator names and options
	def selectGenerator ##{{{
		_buildDefaultGenerator unless @generator;
		cn=@generator[:chain];
		gn=@generator[:name];
		opts=@generator[:options];
		opts[:src] = _sources;
		opts[:tar] = @container.outhome;
		Rsim.ipxact.select(cn,gn,**opts);
	end ##}}}
private
	## _buildDefaultGenerator, build default link generator unless as specified by user
	def _buildDefaultGenerator ##{{{
		@generator={:name=>'link',:chain=>'build',:options=>{}};
	end ##}}}
	## _sources, return all source files according to fileSet
	def _sources ##{{{
		srcs=[];
		@__fs__.each_value do |o|
			srcs.append(*o.source);
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
