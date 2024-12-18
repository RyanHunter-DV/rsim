"""
# Object description:
FlowStep, 
"""
class FlowStep ##{{{
	attr_accessor :group;
	attr_accessor :name;
	#attr_accessor :options;

	attr :actions;
	## initialize(name), 
	def initialize(name); ##{{{
		#puts "#{__FILE__}:start initialize(name) ..."
		@group=nil;
		@name=name;
		@actions={};
		#@options=nil;
	end ##}}}
	## group(name), 
	# specify which group this step belongs to.
	# steps in same group will be dispatched simualtanesouly.
	def group(name); ##{{{
		#puts "#{__FILE__}:start group(name) ..."
	end ##}}}

	## action(&block), declare the detailed action of this step
	# set action with given block
	def action(block); ##{{{
		#puts "#{__FILE__}:start action(&block) ..."
		@actions[block.source_location]= block;
	end ##}}}

	## execute(**opts), description
	def execute(context,**opts); ##{{{
		#puts "#{__FILE__}:start execute(**opts) ..."
		#@options = opts; # setup built-in options available for action blocks.
		@actions.each_pair do |loc,block|
			context.currentOption= opts;
			context.instance_eval &block;
			context.currentOption= nil;
		end
	end ##}}}


end ##}}}