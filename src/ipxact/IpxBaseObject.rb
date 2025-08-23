class IpxBaseObject
	attr_accessor :node_path;
	def initialize(p)
		@node_path = p;
	end

	def finalize
		NodeApp.info("Finalizing #{self.class.name} #{self.name}", 8)
	end
end