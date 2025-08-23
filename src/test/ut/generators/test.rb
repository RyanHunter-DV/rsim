#! /usr/bin/env ruby

puts "ENV['RUBY_LIB'] = #{ENV['RUBY_LIB']}"
$LOAD_PATH << ENV['RUBY_LIB']



require_relative '../../../app/RsApp'
require_relative '../../../ipxact/generator/init'

generator :node_load do
	exe "echo"
	arg :name,:value=>'${name}', :required => true
	arg :out,:value=>'--out ${out}', :required => true
	phase 0
end
generator :build do
	exe "echo"
	arg :name,:value=>'${name}', :required => true
	arg :out,:value=>'--out ${out}', :required => true
	phase 1
end

chain :test do
	define_singleton_method(:out) do
		return 'out'
	end
	generator :node_load do
		param :name => 'node_load'
		param :out => chain.out
	end
	generator :build do
		param :name => 'build'
		param :out => chain.out
	end
end

def main
	puts("Testing generators")
	RsApp.init;
	RsApp.chain(:test).execute({});
end

main;