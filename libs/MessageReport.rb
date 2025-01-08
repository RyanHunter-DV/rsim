"""
# Object description:
MessageReport, description
"""
class MessageReport

	attr :__verbo__; # max verbosity, by default is 2
	# debug mode flag, when is true, messages will report with location
	attr :__debug__; 
	# logger for all information
	attr :logger;

	attr_accessor :count;
	## initialize, description
	def initialize(ui); ##{{{
		@count={:info=>0,:warning=>0,:error=>0};
		_setupConfig(ui);
	end ##}}}


	## error(msg), description
	def error(msg,logger=nil,color=:RED); ##{{{
		m = _format(:error,msg,caller(1)[0],color);
		_print(m,logger);
	end ##}}}

	## info(msg,verbo=2), description
	def info(msg,depth,verbo=2,logger=nil,color=:GREEN); ##{{{
		return if verbo > @__verbo__;
		m = _format(:info,msg,caller(depth+1)[0],color);
		_print(m,logger);
	end ##}}}
	## fatal(sig,msg), report message with fatal severity and exit immediately with the given sig
	def fatal(sig,msg) ##{{{
		m=_format(:error,msg,caller(1)[0],:RED);
		_print(m,logger);
		exit sig;
	end ##}}}

private

	## _setupConfig(c), description
	# according to given config object, setup message report settings
	def _setupConfig(ui); ##{{{
		@__verbo__ = ui.options[:verbosity].to_i;
		@__debug__ = ui.options[:debug];
		Rsim.info("setup max verbosity #{@__verbo__}",5);
		Rsim.info("setup log dirs: #{ui.outs[:logs]}",5);
		_setupLogger(ui.options[:log]);
		_setupLogDir(ui.outs[:logs]);
	end ##}}}
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
end
