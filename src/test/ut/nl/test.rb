#! /usr/bin/env ruby

puts "ENV['RUBY_LIB'] = #{ENV['RUBY_LIB']}"
$LOAD_PATH << ENV['RUBY_LIB']



require_relative '../../../app/RsApp'
require_relative '../../../ipxact/generator/init'


def main
	puts("Testing generators")
	RsApp.init;
	RsApp.chain(:test).execute({});
end

main;
