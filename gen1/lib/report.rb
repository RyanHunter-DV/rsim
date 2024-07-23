## File for storing report related contents, if requires more objects or files, can add a report dir within the lib doc.
## Actions of report, can be log and display for now.
## 
## # class Message
"""
# Object description:
Message, object processed by Reporter
"""
require 'common/Shell.rb'
class Message ##{{{

	attr :severity; # :info,:warning,:error,:fatal
	attr :rawMessage;
	attr :position;
	attr :manualActions;

	@@actions=nil;

	## The Message object that has format information, severity etc.
	## ## def initialize
	## **args**
	## - msg, the message string
	## - sev, the severity of message, one of :info,:warning,:error,:fatal
	## initialize(msg,sev), description
	def initialize(msg,pos,sev); ##{{{
		setupDefaultActions if @@actions==nil;
		@position=pos;@rawMessage=msg;
		@severity=sev.to_sym;
		@manualActions=nil;
	end ##}}}
	## setupDefaultActions, default actions for all message instances
	def setupDefaultActions; ##{{{
		@@actions={};
		[:info,:warning,:error,:fatal].each do |sev|
			@@actions[sev]=[:DISPLAY,:LOG];
		end
	end ##}}}
	## actions, return actions of this message, by default its :DISPLAY and :LOG, users
	## can change it through message configurations.
	def actions; ##{{{
		return @manualActions if @manualActions and (not @manualActions.empty?);
		return @@actions[@severity];
	end ##}}}
	## actions=(as), specifically for this message's actions.
	def actions=(as); ##{{{
		@manualActions=as;
	end ##}}}

	## formatted, return a formatted message string accoring to current type
	# format like:
	# (I/W/E/F)[SystemTime][Position] message
	def formatted; ##{{{
		tag=@severity.to_s[0].upcase;
		stime=Time.now();
		pos=@position;
		msg=@rawMessage;
		fm=%Q|(#{tag})[#{stime}][#{pos}]#{msg}|;
		return fm;
	end ##}}}

	
end ##}}}
## # class Logger
## Open log, record to log file.
"""
# Object description:
Logger, description
"""
class Logger ##{{{
	attr :logh;
	## ## def initialize
	## **args**:
	## - logf, the log file name.
	## 1. check log path, `out/logs/<time stamp>/<logname>.log` if not exists out/logs, then build the dir recursively
	## 2. create a new dir with time stamp, and check if current link exists, need remove and link to current time stamp, else link it directly.
	## 3. open it and assign the handler to @fh.
	## initialize(logf), description
	def initialize(home,file); ##{{{
		t=Time.new.to_s.gsub(/[ \+:]/,'_');
		fp=File.join(home,t,file);
		Rsim.info("fp: (#{fp})",9,:DISPLAY);
		Shell.buildFileRecursively(fp);
		@logh = File.open(fp,'w');
	end ##}}}
	## ## def record
	## record the formatted message into log file.
	## record, description
	def record(msg); ##{{{
		#puts "#{__FILE__}:(record) is not ready yet."
		@logh.write(%Q|#{msg}\n|);
	end ##}}}
	## ## def close
	## if current @fh is opened, then close it, else do nothing.
	## close, description
	def close; ##{{{
		#puts "#{__FILE__}:(close) is not ready yet."
		@logh.close;
	end ##}}}
	
end ##}}}
## # class Reporter
"""
# Object description:
Reporter, description
"""
class Reporter ##{{{
	attr :verboLimit;
	attr :log;
	## ## def initialize
	## 1. setup default actions for different severity reports
	## 	1. severity -> info, action -> LOG, DISPLAY
	## 	2. severity -> warning, action -> LOG, DISPLAY
	## 	2. severity -> error, action -> LOG, DISPLAY
	## 	2. severity -> fatal, action -> LOG, DISPLAY
	## initialize, description
	def initialize; ##{{{
		@verboLimit=9; # after initial, it's maximum limit.
		@log=nil;
	end ##}}}
	
	## ## def initFromUI
	## - ui, the ui object
	## **steps**
	## 1. initLog(ui.logfile) -> @log=Logger.new()
	## initLog(logfile), description
	def initLog(home,file); ##{{{
		@log = Logger.new(home,file);
	end ##}}}
	## setupVerboLimit(val), description
	def setupVerboLimit(val); ##{{{
		@verboLimit=val;
	end ##}}}

	## exceedVerboLimit(v), return true if verboLimit < v, else return false
	def exceedVerboLimit(v); ##{{{
		return true if @verboLimit < v;
		return false;
	end ##}}}
	## ## def display
	## **args**
	## - msg, the message information
	## **steps**:
	## 1. puts msg.
	## 
	## display(msg), display message to screen
	def display(msg); ##{{{
		puts msg;
	end ##}}}
	## ## def log
	## **args**
	## - msg, the message information
	## **steps**;
	## 1. if @log.opened, then @log.record(msg)
	## 
	## log(msg), log message to log file
	def log(msg); ##{{{
		#fatal("Logger not inited",:DISPLAY) unless @log;
		raise FatalE.new("Logger not inited",:DISPLAY) unless @log;
		@log.record(msg);
	end ##}}}

	## ## def close
	## - called by main tool steps, to close the opened log, @log.close
	## close, 
	def close; ##{{{
		@log.close;
	end ##}}}

	## fatal(msg,actions=[]), report with fatal severity
	def fatal(msg,actions=[],depth=0); ##{{{
		pos=caller(depth+1)[0];
		m=Message.new(msg,pos,:fatal);
		actions=[actions] unless actions.is_a?(Array);
		m.actions= actions unless actions.empty?;
		m.actions.each do |a|
			a=a.to_s.downcase.to_sym;
			self.send(a,m.formatted);
		end
		
	end ##}}}
	## error(msg,actions=[]), description
	def error(msg,actions=[],depth=0); ##{{{
		pos=caller(depth+1)[0];
		m=Message.new(msg,pos,:error);
		actions=[actions] unless actions.is_a?(Array);
		m.actions= actions unless actions.empty?;
		puts "actions of error: #{m.actions}"
		m.actions.each do |a|
			a=a.to_s.downcase.to_sym;
			self.send(a,m.formatted);
		end
	end ##}}}
	## ## def info
	## print information according to given verbo
	## **args**
	## - msg, the message string.
	## - verbo=5, verbosity of this message, if the verbo > than the verboLimit, then this message will be ignored, else to display it with formatted output.
	## **steps**:
	## 1. if exceedVerboLimit(verbo), return
	## 2. create a new Message object, m = Message.new(msg,:info)
	## 3. m.actions[:info].each loop
	## 	1. action.to_s.downcase.to_sym!
	## 	2. call self.send(action,m.formatted)
	## info(msg,verbo=5), display info severity message
	def info(msg,verbo=5,actions=[],depth=0); ##{{{
		pos=caller(depth+1)[0];
		return if exceedVerboLimit(verbo);
		m=Message.new(msg,pos,:info);
		actions=[actions] unless actions.is_a?(Array);
		m.actions= actions unless actions.empty?;
		m.actions.each do |a|
			a=a.to_s.downcase.to_sym;
			self.send(a,m.formatted);
		end
	end ##}}}
end ##}}}
## 
## 