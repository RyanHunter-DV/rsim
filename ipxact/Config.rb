"""
# Object description:
Config, 
config ipx database
"""
class Config <IpxData


	# stores the node blocks from declaring this config
	# [:location] => Proc
	attr :nodes;
	# before elaborate, needs are hash of all required component name and view
	# {<component instname>=><view name>}
	# after elaborate, needs are the component instance name and object
	# {<component instname>=><component inst object>}
	attr :needs;
	# before elaborate is reference name, after elaborate is object
	attr :design;
	attr :eda;
	attr :rawfiles;

	attr_accessor :outhome;

	## initialize
	def initialize(vlnv,opts={}); ##{{{
		@needs={};@design=nil;
		@nodes={};
		super(:id=>vlnv,:ipxact=>:config);
		@rawfiles=[];
	end ##}}}

	## components, return all needed components
	#TODO
	def components ##{{{
		
	end ##}}}

	##### node commands {
	# config's node commands will be executed at the elaborate step, when all objects are already created.
	## need(o),
	# call the need command will actual give the necessary component instance to the config.
	# 1.register the given object into pool that will be built.
	# 2.select generator to certain chain.
	def need(o,v=nil); ##{{{
		@needs[o.to_s]=v;
	end ##}}}
	## design(r), design reference name
	def design(r) ##{{{
		@design=r.to_s;
	end ##}}}
	## simulator(n,&block), specify simulator and options that necessary for it
	def simulator(n=nil,&block) ##{{{
		#TODO, not ready yet.
		return @eda unless n;
		@eda={};
		@eda[:name]=n.to_s.capitalize;
		@eda[:exe]= block;
	end ##}}}
	##### }

	## elaborate, 
	# 1.eval the node block
	def elaborate; ##{{{
		Rsim.info("elaborating config #{@id} ...",3);
		Rsim.exception(NodeE,:reason=>'no design reference specified by config') unless @design;
		n=@design;
		@design=Rsim.ipxact.find(n,:design);
		Rsim.exception(NodeE,:reason=>"cannot find design ref(#{n})") unless @design;
		os={};
		@needs.each_pair do |name,view|
			c=@design.send(name.to_sym);
			Rsim.exception("instance(#{n}) of component(#{name}) not declared in design") unless c;
			c.selectView(view);
			c.config=self;
			os[name]=c;
		end
		@needs=os;
		@outhome=File.join(Rsim.ui.outs[:root],'configs',@id);
	end ##}}}

	## finalize, 
	def finalize; ##{{{
		@needs.each_pair do |name,o|
			Rsim.info("finalize component(#{o.id}) ...",3);
			o.finalize;
		end
		_dumpMetaData;
	end ##}}}

	## filelist(f), called by buildflow, to setup basic filelist files
	def filelist(f=nil) ##{{{
		return @rawfiles unless f;
		@rawfiles << f;
	end ##}}}
private
	## _dumpMetaData, dump the config data information
	def _dumpMetaData ##{{{
		#@metadata.record(:node,@root);
		@metadata.record(:outhome,@outhome);
		@metadata.record(:design,@design.id);
		@metadata.record(:needs,{});
		@needs.each_pair do |n,o|
			@metadata.record(n,o.id,:needs);
		end
		@metadata.write(@outhome);
	end ##}}}
end
