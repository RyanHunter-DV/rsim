"""
# Object description:
PluginManager, description
"""
class PluginManager ##{{{
	## initialize, description
	def initialize; ##{{{
		#puts "#{__FILE__}:start initialize ..."
	end ##}}}

	## dynamicLoading(ps,incs),
	# ps: plugin names
	# incs: search path
	def dynamicLoading(ps,incs); ##{{{
		#puts "#{__FILE__}:start dynamicLoading(ps,incs) ..."
		Rsim.info("loading plugins(#{ps}),incs(#{incs})",5);
		ps.each do |pname|
			fn=find(pname+'.rb',incs);
			Rsim.exception(LoadE,:reason=>"Cannot load plugin(#{pname}), cannot find it.") if fn==nil;
			loading(fn);
		end
	end ##}}}
	## register(flow), register flow object into current plugin manager
	# so that by executing with given flow name, can invoke the flow registered in
	# current manager
	def register(flow); ##{{{
		#puts "#{__FILE__}:start register(flow) ..."
		message = flow.name.to_sym;
		define_singleton_method message do |**opts| ##{{{
			Rsim.info("execute flow, opts: #{opts}",5);
			flow.execute(**opts);
		end ##}}}
	end ##}}}

	## execute(flows), description
	# executing given flows
	def execute(flows); ##{{{
		flows.each_pair do |fn,opts|
			Rsim.info("sending message: #{fn}(#{opts})",5);
			self.send(fn,**opts);
		end
	end ##}}}

private
	## find(name,incs), description
	# if found, return the existing path.
	# if not found, return nil;
	def find(name,incs); ##{{{
		#puts "#{__FILE__}:start find(name,incs) ..."
		incs.each do |path|
			Rsim.info("search file(#{name}) in path(#{path})",5);
			#path = Rsim.os.translatePathName(path);
			if Rsim.os.fileExists?(name,path)
				$LOAD_PATH << path; # add the plugin path into load path
				Rsim.info("adding(#{path}) into $LOAD_PATH")
				return File.join(path,name);
			end
		end
		return nil;
	end ##}}}

	## loading(fn), the given file is an existing full path file
	# can be loaded by: load, so that the code will be executed
	# in global scope
	def loading(fn); ##{{{
		Rsim.info("loading #{fn}")
		load fn;
	end ##}}}
end ##}}}

require 'libs/RsimFlow.rb'