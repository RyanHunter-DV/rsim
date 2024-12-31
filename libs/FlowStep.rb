"""
# Object description:
FlowStep, represents the Generator in IP-XACT
"""
class FlowStep ##{{{
	attr_accessor :group;
	attr_accessor :name; # the generator name
	attr_accessor :root; #root path for building and executing the command file.

	attr :actions;
	attr :__cmds__;
	# job type, one of :system, :procedure
	attr :__jtype__;
	attr :exec;
	# the param that overwritten by config or other object must
	# has the same data type with the default value
	attr :__params__;
	## initialize(name), 
	def initialize(n); ##{{{
		#puts "#{__FILE__}:start initialize(name) ..."
		@group=nil;
		@name=n.to_s;
		@actions={};
		@__cmds__=[]; # command lines will be built to command file.
		@root='';
		@exec='';
		@__jtype__=:procedure;
		@__params__={};
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
	## command(s), add the given command string s into command file: @__cmds__
	def command(s); ##{{{
		@__cmds__ << s+';';
	end ##}}}
	## exe(e), description
	def exe(e); ##{{{
		@exec=e.to_s;
		@__jtype__ = :system;
	end ##}}}
	## phase(p), 
	# set execute phase, different phase generators will
	# be called serial
	#TODO
	def phase(p); ##{{{
	end ##}}}
	## parameter(**pairs), 
	# set parameter name and default value and type
	def parameter(**pairs); ##{{{
		pairs.each_pair do |pn,d|
			@__params__[pn] = d;
		end
	end ##}}}

	## execute(**opts), description
	def execute; ##{{{
		#puts "#{__FILE__}:start execute(**opts) ..."
		#@options = opts; # setup built-in options available for action blocks.
		if @__jtype__==:system
			#1.evaluate all action blocks, currently supports only one action.
			cmdf=%Q|#{@name}.cmd|;
			@actions.each_pair do |loc,block|
				self.instance_eval &block;
				_buildCommandFile(cmdf);
			end
			#2.build command file into root path, the @root must be set at finalize step
			return %Q|cd #{root};source #{cmdf}|;
		end
	end ##}}}



end ##}}}