"""
# Object description:
AbstractionDefinition, 
the abstraction object used to store information related to the abstraction definitions
"""
class AbstractionDefinition < IpxData ##{{{
	
	attr :__params__;
	attr :__ports__;
	## initialize, description
	def initialize(id); ##{{{
		super(id);
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
	## param(**opts), declare parameters
	def param(**opts); ##{{{
		opts.each_pair do |pn,d|
			p=IpxParameter.new(pn,d);
			__params__[p.name]= p;
		end
	end ##}}}
	######}


	## finalize, 
	# calling finalize to replace current parameter place holders with current parameter value
	def finalize; ##{{{
		@__ports__[:wire].each do |w|
			#TODO, replace parameter holders to values in abstraction.
		end
	end ##}}}

end ##}}}