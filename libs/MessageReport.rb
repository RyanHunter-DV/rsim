"""
# Object description:
MessageReport, description
"""
class MessageReport ##{{{

	attr :__verbo__; # max verbosity, by default is 2
	attr :__configed__;

	attr_accessor :count;
	## initialize, description
	def initialize; ##{{{
		#puts "#{__FILE__}:start initialize ..."
		@__verbo__=2;
		@__configed__=false;
		@count={:info=>0,:warning=>0,:error=>0};
	end ##}}}

	## setupConfig(c), description
	# according to given config object, setup message report settings
	def setupConfig(c); ##{{{
		@__verbo__ = c.reportMaxVerbosity;
		@__configed__=true;
		Rsim.info("setup max verbosity #{@__verbo__}",5);
	end ##}}}

	## error(msg), description
	def error(msg,color=:RED); ##{{{
		m = _format(:error,msg,caller(1)[0],color);
		puts m;
	end ##}}}

	## info(msg,verbo=2), description
	def info(msg,depth,verbo=2,color=:GREEN); ##{{{
		return if @__configed__ and verbo > @__verbo__;
		m = _format(:info,msg,caller(depth+1)[0],color);
		puts m;
	end ##}}}
private
	## _colorCode(n), description
	def _colorCode(n); ##{{{
		return "\033[0m" if n==:RESTORE;
		return "\033[41m" if n==:RED;
		return "\033[42m" if n==:GREEN;
	end ##}}}
	## _format(sev,msg,loc), description
	def _format(sev,msg,loc,color=:NONE); ##{{{
		sp=loc.split(':');
		flag=sev.to_s[0].upcase;
		fmt="[#{_colorCode(color)}#{flag}-#{@count[sev]}#{_colorCode(:RESTORE)}]@(#{sp[0]}:#{sp[1]}) #{msg}";
		@count[sev]+=1;
		return fmt;
	end ##}}}
end ##}}}