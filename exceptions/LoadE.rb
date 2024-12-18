# exception while loading plugins, or other files
"""
# Object description:
LoadE, load exception description
"""
class LoadE < RsimExceptionBase ##{{{
	
	## initialize(**opts), description
	def initialize(**opts); ##{{{
		puts "#{__FILE__}:start initialize(**opts) ..."
		opts[:exit] = true;
		opts[:exitSignal] = 1;
		super('LOAD-E',**opts);
	end ##}}}
end ##}}}