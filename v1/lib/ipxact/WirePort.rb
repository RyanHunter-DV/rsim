"""
# Object description:
WirePort, for all Wired port data
"""
require 'lib/ipxact/IpXactData.rb'
class WirePort < IpXactData ##{{{

	attr :name;
	attr :qualifier;

	# formats is {}
	# [:system] ...
	# [:master]
	# [:slave]
	attr :dir;
	attr :width;
	attr :presence;
	
	## initialize(n), description
	def initialize(n); ##{{{
		puts "#{__FILE__}:(initialize(n)) is not ready yet."
		@name[:logical] = n.to_s;
		@name[:display] = n.to_s;
		@dir={};@width={};@presence={};
		super(:wire);
	end ##}}}
	## display(n), set display name
	def display(n); ##{{{
		puts "#{__FILE__}:(display(n)) is not ready yet."
		@name[:display]=n.to_s;
	end ##}}}
	## isAddress, 
	def isAddress; ##{{{
		puts "#{__FILE__}:(isAddress) is not ready yet."
		@qualifier = :isAddress;
	end ##}}}
	def isClock; ##{{{
		puts "#{__FILE__}:(isClock) is not ready yet."
		@qualifier = :isClock;
	end ##}}}
	def isReset; ##{{{
		puts "#{__FILE__}:(isReset) is not ready yet."
		@qualifier = :isReset;
	end ##}}}
	def isData;  ##{{{
		puts "#{__FILE__}:(isData) is not ready yet."
		@qualifier = :isData;
	end ##}}}
	## onSystem(dir,**opts), specify behaviors when onSystem
	def onSystem(d,**opts={}); ##{{{
		puts "#{__FILE__}:(onSystem(dir,**opts)) is not ready yet."
		@dir[:system] = d.to_sym;
		@width[:system]=opts[:width] if opts.has_key?(:width);
		@presence[:system]=opts[:presence] if opts.has_key?(:presence);
	end ##}}}
	def onMaster(d,**opts={}); ##{{{
		puts "#{__FILE__}:(onMaster(dir,**opts)) is not ready yet."
		@dir[:master] = d.to_sym;
		@width[:master]=opts[:width] if opts.has_key?(:width);
		@presence[:master]=opts[:presence] if opts.has_key?(:presence);
	end ##}}}
	def onSlave(d,**opts={}); ##{{{
		puts "#{__FILE__}:(onSlave(dir,**opts)) is not ready yet."
		@dir[:slave] = d.to_sym;
		@width[:slave]=opts[:width] if opts.has_key?(:width);
		@presence[:slave]=opts[:presence] if opts.has_key?(:presence);
	end ##}}}
end ##}}}