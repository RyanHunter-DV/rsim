"""
# Object description:
IpXactData, base and common object for IP-XACT
"""
class IpXactData
	
	attr_accessor :datatype;
	attr :nodes;
	attr :desc;
	## initialize(t), description
	def initialize(dt); ##{{{
		puts "#{__FILE__}:(initialize(t)) is not ready yet."
		@datatype=dt.to_sym;
		@nodes=[];@desc='';
	end ##}}}

	# for IP-XACT data, support name types are: vlnv, envId and nameGroup
	def setupNameId(val,t=:vlnv)
		var=%Q|@#{t}|;
		self.instance_variable_set(var,val);
		if t==:vlnv
			# if is vlnv type, then need return the name
			splitted=val.split('/');
			self.define_singleton_method :name do
				return splitted[2]
			end
		end
		self.define_singleton_method t do
			return self.instance_variable_get(var);
		end
		self.define_singleton_method :id do
			# return the name id by calling a unified method for different
			# datatypes
			return self.instance_variable_get(var);
		end
	end

	## addUserNode(b), description
	def addUserNode(b); ##{{{
		@nodes.append(*b) if b.is_a?(Array);
		@nodes << b;
	end ##}}}
	def evalUserNodes(o) ##{{{
		@nodes.each do |node|
			o.instance_eval &node;
		end
	end ##}}}
	def nodes
		return @nodes;
	end
	## description(d)
	def description(d); ##{{{
		puts "#{__FILE__}:(description(d)) is not ready yet."
		@desc = d;
	end ##}}}
end
