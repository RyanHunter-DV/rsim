class DesignConfiguration < IpXactData

	attr :needs;
	attr :compopts;
	attr :elabopts;

	def initialize(name)
		super(:config);
		setupNameId(name,:nameGroup);
		@needs={};
		@compopts=[];@elabopts=[];
	end

	def clones(p)
		c.addUserNodes(p.nodes);
	end

	## user node commands
	# need, include a component which will be built.
	# example: need design.instname => :viewname
	def need(io,vname)
		needs[io]={:view=>vname};
	end
	# compopt, option string directly set to compile flow
	def compopt(*args)
		@compopts.append(*args);
	end
	# elabopt, option string directly set to compile flow
	def elabopt(*args)
		@elabopts.append(*args);
	end
	# generatorChain configs, for buildflow only.
	def generatorChain
		#TODO
	end

	# design, return the design object.
	def design
		return MetaData.design;
	end

	def finalize
		evalUserNodes(self);
		Rsim.simulator.compopts(@compopts);
		Rsim.simulator.elabopts(@elabopts);
	end
	## elaborate, building this configs
	def elaborate ##{{{
		needs.each_pair do |o,opts|
			o.elaborate(self,**opts);
		end
	end ##}}}
end

def config(vlnv,**opts,&block)
	c = DesignConfiguration.new(vlnv);
	if opts.has_key?(:clones)
		p=MetaData.find(opts[:clones],:config) 
		c.clones(p);
	end
	MetaData.register(c);
	c.addUserNode(block);
end

