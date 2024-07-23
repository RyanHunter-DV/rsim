"""
# Object description:
Simulator, the generic object facing to the Rsim tool, reading commands and options
from user nodes, and translated to specific EDA supported options.
"""
class Simulator ##{{{
	## initialize(eda,step), 
	# eda is the mark of eda tool, with symbol type.
	# step is the detailed eda step, such as compile, elaborate, run ...
	def initialize(eda,step); ##{{{
		# if loaded, then not necessary to load it again.
		require "lib/eda/#{eda}.rb";
		@eda = Eda.new();
		@step=step;
	end ##}}}

	## parseNodeString(s), description
	# input string will be like:
	# ['define xxx=xxx','define xxx','CC xxx',...]
	def parseNodeString(s); ##{{{
		#puts "#{__FILE__}:(parseNodeString(s)) is not ready yet."
		message=%Q|parse#{@step.capitalize}Options|;
		raise FatalE.new("eda(#{@eda.name}) has no method(#{message})") unless @eda.respond_to?(message);
		@eda.send(message,s);
	end ##}}}
	## command, return eda command
	def command; ##{{{
		#puts "#{__FILE__}:(command) is not ready yet."
		return @eda.command(@step);
	end ##}}}
end ##}}}