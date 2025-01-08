class UIE < RsimExceptionBase
	
	## initialize(**opts), description
	def initialize(**opts); ##{{{
		opts[:exit] = true;
		opts[:exitSignal] = 1;
		super('UI-E',**opts);
	end ##}}}
end
