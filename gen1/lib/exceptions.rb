"""
# Object description:
FatalE, exception processor for Rsim fatal.
"""
class RsimE < Exception ##{{{}}}
	RSIM_SUCCESS_SIG = 0;
	RSIM_FATAL_SIG   = 1;
	RSIM_USERE_SIG   = 2;

	attr :severity;
	attr :message;
	attr :actions;
	attr :exit;
	attr :exitSignal;
	## initialize(sev), description
	def initialize(sev,msg,action=[]); ##{{{
		@severity=sev.to_sym;
		@message=msg;
		@actions=action;
	end ##}}}
	## needExit=(b,sig), set if this exception will cause exit or not.
	def needExit(b,sig); ##{{{
		@exit= b;
		@exitSignal= sig;
	end ##}}}
	## process, to process this exception by given sub exception's configurations
	def process; ##{{{
		Rsim.send(@severity,@message,@actions);
		Rsim.exit(@exitSignal) if @exit==true;
	end ##}}}
end ##}}}
class FatalE < RsimE ##{{{

	## initialize(msg,action), 
	# setup exception with message and actions
	def initialize(msg,action=[]); ##{{{
		super(:fatal,msg,action);
		needExit(true,RSIM_FATAL_SIG);
	end ##}}}
end ##}}}

"""
# Object description:
NodeE, exceptions while reading node
"""
class NodeE < RsimE ##{{{
	## initialize(msg,action=[]), description
	def initialize(msg,action=[]); ##{{{
		#puts "#{__FILE__}:(initialize(msg,action=[])) is not ready yet."
		super(:error,msg,action)
		needExit(true,RSIM_USERE_SIG);
	end ##}}}
end ##}}}