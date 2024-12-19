# exceptions while reading the node files, or which has syntax or other issues related to node file.
class NodeE < RsimExceptionBase ##{{{
	
	## initialize(**opts), description
	def initialize(**opts); ##{{{
		puts "#{__FILE__}:start initialize(**opts) ..."
		opts[:exit] = true;
		opts[:exitSignal] = 1;
		super('NODE-E',**opts);
	end ##}}}
end ##}}}