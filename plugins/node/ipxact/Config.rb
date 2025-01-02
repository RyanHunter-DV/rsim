"""
# Object description:
Config, 
config ipx database
"""
class Config <IpxData ##{{{

	#[:buildflow]=>[], store generate executors
	attr_accessor :needs;
	attr_accessor :generators;

	# stores the node blocks from declaring this config
	# [:location] => Proc
	attr :nodes;

	## initialize
	def initialize(vlnv); ##{{{
		@needs=[];
		@generators={:buildflow=>[]};
		@nodes={};
		super(vlnv);
	end ##}}}


	##### node commands {
	# config's node commands will be executed at the elaborate step, when all objects are already created.
	## need(o),
	# call the need command will actual give the necessary component instance to the config.
	# 1.register the given object into pool that will be built.
	# 2.select generator to certain chain.
	def need(o); ##{{{
		@needs << o;
	end ##}}}
	##### }

	## elaborate, 
	# 1.eval the node block
	def elaborate; ##{{{
		@nodes.each_pair do |loc,b|
			# TODO, use loc for exception process later
			self.instance_eval &b;
		end
	end ##}}}

	## finalize, 
	# arrange the generators for different phases, such as for 'buildflow' group
	def finalize; ##{{{
		_assembleGenerators(:buildflow);
	end ##}}}
private
	## _assembleGenerators(gn), description
	def _assembleGenerators(group); ##{{{
		# find generator chain definition
		gc=DataBase.find(group);
		# needs.each
		@needs.each do |ci|
			# 1.2.find generator in that chain with certain group name.
			ge=ci.generator[group];
			g=gc.find(ge.name);
			Rsim.exception(NodeE,:reason=>"cannot find generator definition #{ge.name}") unless g;
			ge.updateDefinition(g); # update definition
			@generators[group] << ge;
		end
		
	end ##}}}
end ##}}}