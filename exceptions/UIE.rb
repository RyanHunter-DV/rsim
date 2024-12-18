class UIE < RsimExceptionBase ##{{{
	
	## initialize(**opts), description
	def initialize(**opts); ##{{{
		puts "#{__FILE__}:start initialize(**opts) ..."
		opts[:exit] = true;
		opts[:exitSignal] = 1;
		super('UI-E',**opts);
	end ##}}}
end ##}}}