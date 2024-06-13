require 'lib/ipxact/IpxactData.rb'
require 'lib/ipxact/component/RegisterFieldType.rb'

"""
# Object description:
RegisterType, class to place the information of the component's registers
User node description:
component ... do
	map 'name' do
		# bank
		#subspaeMap
		addressBlock 'name',0x1000,10,32 do
			usage :register
			register 'r0',0x0,32,'read-write' do
				# name,bitOffset,bitWidth,access
				field 'r0_f0',0,4,'read-write' do
					# readAction, by default only read when not set.
					modified :oneToClear # oneToToggle
				end
			end
		end
	end
end
"""
class RegisterType ##{{{
	attr_accessor :name;
	attr_accessor :offset;
	attr_accessor :size;
	attr_accessor :access;

	attr :fields;
	## initialize, description
	# n: name, s: size
	def initialize(n,offset,s,access); ##{{{
		@name=n;@offset=offset;
		@size=s;@access=access.to_s;
		@fields={};
	end ##}}}

	#  n->name,bo->bitOffset,bw->bitWidth,a->access
	def field(n,bo,bw,a,&block); ##{{{
		f=RegisterFieldType.new(n,bo,bw,a);
		f.instance_eval block;
		@fields[n.to_s]= f;
	end ##}}}


end ##}}}
