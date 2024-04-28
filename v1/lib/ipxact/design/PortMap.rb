class PortMap

	attr :target;
	attr :source;

	def initialize
		@target={:type=>:port,:value=>''};
		@source={:type=>:port,:value=>''};
	end

	def source(p,*vec)
		@source[:type] = :refname if p.is_a?(:String);
		@source[:value]= p;
		@source[:left]= vec[0];
		@source[:right]= vec[1];
	end
	def target(p,*vec)
		@target[:type] = :refname if p.is_a?(:String);
		@target[:value]= p;
		@target[:left]= vec[0];
		@target[:right]= vec[1];
	end

end
