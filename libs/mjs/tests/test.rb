#! /usr/bin/env ruby


require_relative '../MultJobSystem'
require_relative '../MjsCommand'

MultJobSystem.run(2);

#job=MjsCommand.new(:external,self){"echo 'Hello, World! command 1';sleep 5 ;"};
#p=MultJobSystem.dispatch(job);
#job2=MjsCommand.new(:external,self){"echo 'Hello, World! command 2';sleep 2 ;"};
#p2=MultJobSystem.dispatch(job2);
ps=[];
1.times do |i|
	job=MjsCommand.new(:external,self){"echo 'Hello, World! command #{i}';sleep #{i+5} ;"};
	ps << MultJobSystem.dispatch(job);
end

ps.each do |p|
	p.await;
end

puts "main process finished time: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

exit 0;