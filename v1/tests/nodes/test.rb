#! /usr/bin/env ruby

testhome=File.absolute_path(File.dirname(__FILE__));
toolhome=File.absolute_path(File.join(testhome,'../../'));
puts "toolhome: #{toolhome}"
$LOAD_PATH << toolhome;

$STEM='/Users/ryanhunter/project/local/rsim/v1/tests/nodes';
#$LOAD_PATH << $STEM;

require 'lib/nodes/MetaData.rb'
require 'lib/nodes/NodeManager.rb'

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

class TmpUi
	attr_accessor :entries;
	attr_accessor :stem;
	def initialize
		@entries=['node.rh'];
		@stem=$STEM;
	end
end

def main
	Rsim.info("main initialize",9);
	ui=TmpUi.new();
	nm=NodeManager.new(ui);
	Rsim.info("main initialize done",9);

	Rsim.info("finalizing metadata",9);
	MetaData.finalize;
end

begin
	Rsim.info("calling main",9)
	main();
rescue NodeException => e
	e.process;
rescue ToolException => e
	e.process;
end
