"""
# Object description:
MessageReport, description
"""
class MessageReport ##{{{

	attr :__verbo__; # max verbosity, by default is 2
	attr :__configed__;
	# debug mode flag, when is true, messages will report with location
	attr :__debug__; 
	# logger for all information
	attr :logger;

	attr_accessor :count;
	## initialize, description
	def initialize; ##{{{
		#puts "#{__FILE__}:start initialize ..."
		@__verbo__=2;
		@__configed__=false;
		@__debug__=false;
		@count={:info=>0,:warning=>0,:error=>0};
		_setupLogger('rsim.log');
	end ##}}}

	## setupConfig(c), description
	# according to given config object, setup message report settings
	def setupConfig(c,ui); ##{{{
		@__verbo__ = c.reportMaxVerbosity;
		@__debug__ = c.options[:debug];
		@__configed__=true;
		Rsim.info("setup max verbosity #{@__verbo__}",5);
		Rsim.info("setup log dirs: #{c.outs[:logs]}",5);
		_setupLogDir(c.outs[:logs]);
	end ##}}}

	## error(msg), description
	def error(msg,logger=nil,color=:RED); ##{{{
		m = _format(:error,msg,caller(1)[0],color);
		_print(m,logger);
	end ##}}}

	## info(msg,verbo=2), description
	def info(msg,depth,verbo=2,logger=nil,color=:GREEN); ##{{{
		return if @__configed__ and verbo > @__verbo__;
		m = _format(:info,msg,caller(depth+1)[0],color);
		_print(m,logger);
	end ##}}}
private
	## _setupLogger(logf), description
	# setup the main @logger
	# 1.check if logf exists, move to backup
	# 2.File.open, and set @logger as the file handle
	def _setupLogger(logf); ##{{{
		#TODO, the backup feature works not correct, need test it in linux os.
		system("mv #{logf} #{logf}.bakup") if File.exist?(logf);
		@logger=File.open(logf,'w');
	end ##}}}
	## _setupLogDir(d), 
	# 1.split the d with last folder <out>/logs/,<logd>
	# 2.build dir of out, logs if which not exists
	# 2.check current link in dirname, if exists, remove and relink.
	def _setupLogDir(d); ##{{{
		basename=File.basename(d);
		dirname=File.dirname(d);
		Rsim.os.mkdir(d,:recursive=>true);
		Rsim.os.rm('current',dirname) if Rsim.os.fileExists?('current',dirname);
		Rsim.os.link(d,File.join(dirname,'current'));
	end ##}}}
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
		dinfo='';
		dinfo="@(#{sp[0]}:#{sp[1]})" if @__debug__;
		fmt="[#{_colorCode(color)}#{flag}-#{@count[sev]}#{_colorCode(:RESTORE)}]#{dinfo} #{msg}";
		@count[sev]+=1;
		return fmt;
	end ##}}}
	## _print(msg), description
	# 1.print message with puts
	# 2.log it into the @logger
	# 3.if ulog is not nil, then log it into user log handle as well.
	def _print(msg,ulog); ##{{{
		puts msg;@logger.write(%Q|#{msg}\n|);
		ulog.write(%Q|#{msg}\n|) if ulog;
	end ##}}}
end ##}}}