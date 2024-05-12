#! /usr/bin/env ruby

testhome=File.absolute_path(File.dirname(__FILE__));
toolhome=File.absolute_path(File.join(testhome,'../../'));
puts "toolhome: #{toolhome}"
$LOAD_PATH << toolhome;

#$STEM='/Users/ryanhunter/project/local/rsim/v1/tests/nodes';
#$LOAD_PATH << $STEM;

require 'lib/threads/Command.rb'
require 'lib/threads/Dispatcher.rb'
require 'lib/nodes/NodeManager.rb'
require 'lib/plugin/PluginManager.rb'

require 'lib/Reporter.rb'
module Rsim
	@pm;
	def self.info(msg,verbo=5)
		@reporter=Reporter.new(9) unless @reporter;
		@reporter.info(msg,verbo);
	end
	def self.error(msg)
		@reporter=Reporter.new(9) unless @reporter;
		@reporter.error(msg);
	end
	def self.warning(msg)
		@reporter=Reporter.new(9) unless @reporter;
		@reporter.warning(msg);
	end
	@@declared=false;
	def self.pm
		Rsim.info("call Rsim.pm, pm:(#{@pm})",9);
		if @pm==nil
			if @@declared
				puts "error @pm is registered: #{@pm}"
				exit 3;
			end
			@@declared=true;
			ui=UI.new;
			dp=Dispatcher.new(ui);
			@pm=PluginManager.new();
			Rsim.info("init pm: #{@pm}",9);
			@pm.init(dp,ui);
		end
		return @pm;
	end
	def self.init
		@pm=nil;
	end
end

class UI
	attr_accessor :maxJobs;
	attr_accessor :logdir;
	attr_accessor :plugins;
	def initialize
		@maxJobs=1;
		@logdir='.';
		@plugins=[];
	end
end

def main
	Rsim.init;
	Rsim.info("get pm from Rsim(#{Rsim})",9);
	pm=Rsim.pm;
	Rsim.info("pm from Rsim is #{pm.inspect}",9);
	Rsim.info("pm methods#{pm.methods}",9);
	pm.build;
end

begin
	Rsim.info("calling main",9)
	main();
end
