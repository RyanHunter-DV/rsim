#! /usr/bin/env ruby
$LOAD_PATH << '../..';
require 'mult/JobM.rb'

## main, description
def main; ##{{{
	
	js=[];
	10.times do |i|
		j=Job.new(:system,%Q|sleep #{i};echo "sleep#{i} done"|);
		j.dispatch;
		puts "job id #{i} dispatched"
		js<<j;
	end
	js.each do |j|
		j.wait;
	end
	#j1=Job.new(:system,'sleep 4;echo "sleep4 done"');
	#j0.dispatch;
	#j1.dispatch;
	#j1.wait;
	#j0.wait;
end ##}}}

main;
exit 0;