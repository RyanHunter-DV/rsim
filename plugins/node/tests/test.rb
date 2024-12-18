#! /usr/bin/env ruby

puts "Starting test ...";

$c=nil;

# for test
class OS ##{{{
	
	# :Linux, :Mac, :Windows
	attr :__sep__; # file separator
	attr_accessor :type;
	## initialize, description
	def initialize(t=:Linux); ##{{{
		puts "#{__FILE__}:start initialize ..."
		@type=t.to_sym;
		@__sep__ = {:Linux=>'/',:Mac=>'/',:Windows=>'\\'};
	end ##}}}
	## fileExists?(fn,path='.'), description
	def fileExists?(fn,path=nil); ##{{{
		puts "#{__FILE__}:start fileExists?(fn,path='.') ..."
		fn =File.join(path,fn) unless path==nil;
		fn = _convertPath(fn);
		return true if File.exist?(fn);
		return false;
	end ##}}}
	def readfile(fn); ##{{{
		puts "#{__FILE__}:start readfile(fn) ..."
		fh=File.open(fn,'r');
		contents = fh.readlines();
		fh.close;
		return contents;
	end ##}}}

private
	## _convertPath(org), description
	def _convertPath(org); ##{{{
		puts "#{__FILE__}:start _convertPath(org) ..."
		return org.gsub(/\//,@__sep__[@type]);
	end ##}}}
end ##}}}
module Rsim
	@os=OS.new(:Windows);
	## self.os, description
	def self.os; ##{{{
		puts "#{__FILE__}:start self.os ..."
		return @os;
	end ##}}}
end





## node, node method to call like the component
def node; ##{{{
	puts "#{__FILE__}:start node ..."
	fh = File.open('../examples/component.rh','r')
	s=fh.readlines().join("\n");
	eval s;
end ##}}}

path=File.dirname(File.dirname(File.dirname(File.absolute_path(__FILE__))));
puts "load path: (#{path})";
$LOAD_PATH << path;
require 'node/ipxact/Component.rb'

## component(c,&block), description
def component(vlnv,&block); ##{{{
	puts "#{__FILE__}:start component(c,&block) ..."
	$c=Component.new(vlnv);
	$c.instance_eval &block;
end ##}}}

## display, description
def display; ##{{{
	puts "#{__FILE__}:start display ..."
	puts "component: #{$c.id}"
	$c.display;
	#views=$c.views;
	#if views
	#	puts "- views ..."
	#	views.each_value do |v| ##{{{
	#		puts "-- view: #{v.id}"
	#		v.print;
	#		#TODO
	#	end ##}}}
	#else
	#	puts "Error, no view defined by component node"
	#end
end ##}}}

## main, description
def main; ##{{{
	puts "#{__FILE__}:start main ..."
	node;
	display;
end ##}}}

main;