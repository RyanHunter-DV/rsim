require 'lib/ipxact/IpxactData.rb'
class ReigsterFieldType
	attr_accessor :name;
	attr_accessor :bitOffset;
	attr_accessor :bitWidth;
	attr_accessor :access;
	attr_accessor :modifiedWriteValue;

	def initialize(n,bo,bw,a)
		@name=n.to_s;
		@bitOffset=bo;
		@bitWidth =bw;
		@access   = a.to_s;
		@modifiedWriteValue=:modify;
	end

	## user node commands
	def modified(m)
		@modifiedWriteValue=m.to_sym;
	end

end
