"""
# Object description:
ComponentGenerator, object used to store information
of a component generator.
"""
require 'ipxact/IpxData.rb'
class ComponentGenerator < IpxData ##{{{
	attr :groupname;
	attr :runphase;
	attr :exedata;
	attr_accessor :parameters;
	## initialize(name), 
	#
	def initialize(name); ##{{{
		#puts "#{__FILE__}:start initialize(name) ..."
		super(:id=>name);
		@groupname=nil;
		@runphase=0.0; # by default run phase is 0
		@parameters={}; # key => value pairs, in string format
		@exedata={:exe=>nil,:opt=>[]};
	end ##}}}

	# supported commands when using instance_eval
	## group(gn), specify a group name, which will be picked up by generator selector
	def group(gn=nil); ##{{{
		#puts "#{__FILE__}:start group(gn) ..."
		return @groupname unless gn;
		@groupname=gn.to_s;
	end ##}}}
	## phase(v=nil), specify the run phase of the generator
	def phase(v=nil); ##{{{
		#puts "#{__FILE__}:start phase(v=nil) ..."
		return @runphase unless v;
		@runphase=v;
	end ##}}}
	## parameter(**opts), specify parameters by node, with key => value pair
	def parameter(**opts); ##{{{
		#puts "#{__FILE__}:start parameter(**opts) ..."
		opts.each_pair do |k,v|
			@parameters[k.to_s]=v.to_s;
		end
	end ##}}}
	## exe(sformat), string format of the executor
	# 'executor <parameter key> ...'
	# the parameter key are specifieid within '<>' so when executing this
	# generator, the parameter key shall be replaced by the parameter value
	# use backslash to place a real '<>' like: 'bin/exe \<test\>'
	def exe(sformat); ##{{{
		#puts "#{__FILE__}:start exe(sformat) ..."
		splitted=sformat.split(/ +/);
		@exedata[:exe] = splitted[0];
		if splitted.length > 1
			# has options, else not
			splitted.length.times do |i|
				next if i==0; # skip the splitted[0];
				@exedata[:opt]<<splitted[i];
			end
		end
	end ##}}}
	## display, description
	def display; ##{{{
		puts "#{__FILE__}:start display ..."
		puts "type ComponentGenerator";
		puts "- id: #{id}";
		puts "- group: #{@groupname}";
		puts "- phase: #{@runphase}";
		puts "- exe data:";
		puts "-- cmd: #{@exedata[:exe]}";
		puts "-- options: #{@exedata[:opt]}";
		puts "- parameters:";
		@parameters.each_pair do |k,v|
			puts  "-- #{k} => #{v}";
		end
	end ##}}}
end ##}}}