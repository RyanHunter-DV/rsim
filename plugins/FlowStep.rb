"""
# Object description:
FlowStep, 
"""
class FlowStep ##{{{
	attr_accessor :group;
	attr_accessor :name;

	## initialize(name), 
	def initialize(name); ##{{{
		puts "#{__FILE__}:start initialize(name) ..."
		@group=nil;
		@name=name;
	end ##}}}
	## group(name), 
	# specify which group this step belongs to.
	# steps in same group will be dispatched simualtanesouly.
	def group(name); ##{{{
		puts "#{__FILE__}:start group(name) ..."
	end ##}}}

	## action(&block), declare the detailed action of this step
	def action(&block); ##{{{
		puts "#{__FILE__}:start action(&block) ..."
	end ##}}}


end ##}}}