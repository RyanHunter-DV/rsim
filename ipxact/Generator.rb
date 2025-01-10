"""
# Object description:
Generator, represents the Generator definition in IP-XACT
"""
class Generator
	attr_accessor :group;
	attr_accessor :name; # the generator name
	attr_accessor :context;
	attr_accessor :precedences;
	attr_accessor :exec;

	attr :__cmds__;
	# job type, one of :system, :procedure
	attr :__jtype__;
	# the param that overwritten by config or other object must
	# has the same data type with the default value
	attr :__params__;
	attr :__phase__;
	attr :__action__;
	## initialize(name), 
	def initialize(n,c); ##{{{
		#puts "#{__FILE__}:start initialize(name) ..."
		@group=nil;
		@name=n.to_s;
		@__action__=[];
		@__cmds__=[]; # command lines will be built to command file.
		@exec='';
		@__jtype__=:procedure;
		@__params__={};
		@context=c;
		@precedences=[];
		@__phase__ = 0.0;
	end ##}}}

	## action(&block), declare the detailed action of this step
	# set action with given block
	def action(exe=nil,&block); ##{{{
		_setExec(exe) unless exe==nil;
		@__action__ = [block.source_location,block] if block_given?;
		return @__action__ if exe==nil and not block_given?;
	end ##}}}
	## phase(p), 
	# set execute phase, different phase generators will
	# be called serial
	def phase(p); ##{{{
		return @__phase__ if p==nil;
		@__phase__ = p;
	end ##}}}
	## parameter(**pairs), 
	# record parameter name and default value in generator definition class
	# will be set to generator executors with different parameter usage settings.
	def parameter(**pairs); ##{{{
		pairs.each_pair do |pn,d|
			@__params__[pn.to_s] = d;
		end
	end ##}}}

	## hasParam?(n), 
	# return true if vn exists in @__params__
	def hasParam?(n); ##{{{
		n=n.to_s;
		return true if @__params__.has_key?(n);
		return false;
	end ##}}}

	## jobtype, 
	# return the __jtype__
	def jobtype; ##{{{
		return @__jtype__;
	end ##}}}
	## precedent(n), add name of the generator into @precedences
	def precedent(n); ##{{{
		@precedences << n.to_s;
	end ##}}}

private
	def _setExec(e); ##{{{
		@exec=e.to_s;
		@__jtype__ = :system;
	end ##}}}

end
