class WirePort < PortType
	attr_accessor :direction;
	attr_accessor :name;
	attr_accessor :left;
	attr_accessor :right;

	def initialize(n,dir,**opts)
		@name=n;
		@direction = dir.to_sym;
		@left=0;@right=0;
		@left = opts[:left] if opts.has_key?(:left);
		@right = opts[:right] if opts.has_key?(:right);
	end

end
