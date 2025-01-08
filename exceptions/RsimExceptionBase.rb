"""
# Object description:
RsimExceptionBase, base exception object
"""
class RsimExceptionBase < Exception

	attr :__eid__; # exception id
	attr :__exit__;
	attr :__stack__;
	
	attr_accessor :reason;
	attr_accessor :exitSignal;


	## initialize, description
	def initialize(eid,**opts); ##{{{
		@__eid__=eid;
		@reason='Unkown reason !';
		@reason = opts[:reason] if opts.has_key?(:reason);
		@__exit__=false;
		@__exit__=opts[:exit] if opts.has_key?(:exit);
		@exitSignal = opts[:exitSignal] if @__exit__;
		@__stack__='';
		@__stack__=opts[:stack] if opts.has_key?(:stack);
	end ##}}}

	## type, return exception id as string
	def type; ##{{{
		return @__eid__;
	end ##}}}

	## exit?, description
	def exit?; ##{{{
		#puts "#{__FILE__}:start exit? ..."
		return @__exit__;
	end ##}}}

	## stack, return stack information
	def stack; ##{{{
		@__stack__;
	end ##}}}
end
