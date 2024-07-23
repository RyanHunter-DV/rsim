"""
# Object description:
NodeLoader, the main LNS top, stores all loaded data, such as generators, components etc.
"""
require 'lib/nls/generatorChain.rb'
require 'lib/nls/designConfiguration.rb'
class NodeLoader ##{{{
	BUILTINs = ['builtin/build.rh','builtin/compile.rh'];
	
	## initialize, description
	def initialize; ##{{{
	end ##}}}

	## loadBuiltins, load ubiltin components
	def loadBuiltins; ##{{{
		Rsim.info("Start loading builtin components ... ...");
		BUILTINs.each do |p|
			p=File.join($RSIM_ROOT,$version,p)
			raise NodeE.new("builtin(#{p}) not exists") unless File.exist?(p);
			Rsim.info("loading #{p}");
			rhload p,from: :raw;
		end
		Rsim.info("loading builtin components done");
	end ##}}}

	## loading(entries), loading according to the given entries, with format:
	# <path0>/root.rh;<path1>/root.rh
	# all paths shall be exists.
	def loading(es); ##{{{
		loadBuiltins;
		Rsim.info("get entries from ui: #{es}",9);
		entries = es.split(';');
		Rsim.info("get splitted entries:(#{entries})",9)
		entries.each do |entry|
			raise NodeE.new("entry(#{entry}) not exists") unless File.exist?(entry);
			rhload entry,from: :raw;
		end
	end ##}}}
end ##}}}