#! /usr/bin/env ruby

testhome=File.absolute_path(File.dirname(__FILE__));
toolhome=File.absolute_path(File.join(testhome,'../../'));
puts "toolhome: #{toolhome}"
$LOAD_PATH << toolhome;

#$STEM='/Users/ryanhunter/project/local/rsim/v1/tests/nodes';
#$LOAD_PATH << $STEM;

require 'lib/threads/Command.rb'
require 'lib/threads/Dispatcher.rb'

require 'lib/Reporter.rb'
module Rsim
	def self.info(msg,verbo=5)
		@reporter=Reporter.new(9) unless @reporter;
		@reporter.info(msg,verbo);
	end
	def self.error(msg)
		@reporter=Reporter.new(9) unless @reporter;
		@reporter.error(msg);
	end
end

class UI
	attr_accessor :maxJobs;
	attr_accessor :logdir;
	def initialize
		@maxJobs=1;
		@logdir='.';
	end
end

def main
	ui=UI.new;
	dp=Dispatcher.new(ui);
	cmd0=Command.new(self);
	cmd0.add("sleep 3",:extern);
	cmd1=Command.new(self);
	cmd1.add("sleep 4",:extern);
	b= -> { 
		Rsim.info("test for proc exe",9);
	}
	cmd2=Command.new(self);cmd2.add(b,:proc);
	pid0=dp.emit(cmd0);
	pid1=dp.emit(cmd1);
	pid2=dp.emit(cmd2);
	dp.wait(pid0,pid1,pid2);
end

begin
	Rsim.info("calling main",9)
	main();
end
