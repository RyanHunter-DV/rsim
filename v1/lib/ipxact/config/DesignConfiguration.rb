class DesignConfiguration < IpXactData

	attr :needs;
	attr :compopts;
	attr :elabopts;

	def initialize(vlnv)
		super(:config);
		setupNameId(vlnv);
		@needs={};
		@compopts=[];@elabopts=[];
	end

	def clones(p)
		c.addUserNodes(p.nodes);
	end

	## user node commands
	# need, include a component which will be built.
	# example: need design.instname => :viewname
	def need(**pairs)
		pairs.each_pair do |io,vname|
			# io -> instance object, vname -> view name
			needs[io]={:view=>vname};
		end
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
end

def config(vlnv,**opts,&block)
	c = DesignConfiguration.new(vlnv);
	if opts.has_key?(:clones)
		p=MetaData.find(opts[:clones],:config) 
		c.clones(p);
	end
	c.addUserNodes(block);
end

