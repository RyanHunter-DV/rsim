"""
# Object description:
IpXactData, description
"""
class IpXactData ##{{{

	attr_accessor :id;
	# format of nodes=[[loc,block],[loc,block]];
	attr :nodes;

	## initialize(id), description
	def initialize(id); ##{{{
		@id=id.to_s;
		@nodes=[];
	end ##}}}

	## addNodes(loc,n), add user nodes to current config and will be
	# evaled when calling finalize
	def addNodes(loc,n); ##{{{
		@nodes << [loc,n];
	end ##}}}
	## finalize, basic method to eval nodes, if
	# sub classes need special operations, then they need to overwrite this method
	def finalize; ##{{{
		@nodes.each do |node|
			loc=node[0];p=node[1];
			Rsim.info("Finalizing node(#{loc}) in object(#{@id})")
			self.instance_eval &p;
		end
	end ##}}}
end ##}}}