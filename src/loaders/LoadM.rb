class LoadM

	attr_accessor :load_path

	def initialize
		NodeApp.info("LoadM initialized", 5)
		@load_path = []
	end

	def load_node(entry)
		NodeApp.info("Loading node: #{entry}", 5)
		rhload(entry)
	end
end