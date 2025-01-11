"""
# Object description:
AbstractionDefinition, 
the abstraction object used to store information related to the abstraction definitions
"""
require 'ipxact/IpxData.rb'
require 'ipxact/IpxParameter.rb'
require 'ipxact/WirePort.rb'
class AbstractionDefinition < IpxData
	
	attr :__params__;
	attr :__ports__;
	attr :__busref__;
	## initialize, description
	def initialize(id); ##{{{
		super(:id=>id,:ipxact=>:abstraction);
		@__params__={};
		@__ports__={:wire=>[],:trans=>[]};
	end ##}}}

	###### node commands {
	## wire(pn,pt,&block), 
	# pn: port name
	# pt: prot type, :clock,:data,:address
	# block, sub codes to a WirePort object, setting attributes for abstraction
	def wire(pn,pt,&block); ##{{{
		w=WirePort.new(pn);
		w.usedBy :abstraction;
		w.qualifier pt.to_sym;
		w.instance_eval &block;
		@__ports__[:wire] << w;
	end ##}}}
	## parameter(**opts), declare parameters
	def parameter(**opts); ##{{{
		opts.each_pair do |pn,d|
			p=IpxParameter.new(pn,d);
			__params__[p.name]= p;
		end
	end ##}}}
	## bus(vn), setup the reference bus vlnv
	def bus(vn); ##{{{
		@__busref__=vn.to_s; # current is ref name.
	end ##}}}
	######}

	## elaborate, 
	# 1.find the bus definition object from database according to the refname
	def elaborate; ##{{{
		Rsim.exception(NodeE,:reason=>"no bus reference specified for an abstraction") unless @__busref__;
		n=@__busref__;
		@__busref__=DataBase.find(n,:busDefinition);
	end ##}}}

	## finalize, 
	# calling finalize to replace current parameter place holders with current parameter value
	def finalize; ##{{{
		@__ports__[:wire].each do |w|
			#TODO, replace parameter holders to values in abstraction.
		end
	end ##}}}

end
