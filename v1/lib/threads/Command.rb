# Object for commands organizing and passing through the Rsim tool.
"""
# Object description:
Command, object used to store attributes and apis for a command
Which can be internal block, or external command string that can be operated
by this object
"""
class Command

	#TODO, attr fields.
	attr :procedures;
	attr_accessor :scope;

	## initialize(p), description
	def initialize(s); ##{{{
		@scope = s;
		# format:
		# [{:proc=>xxx,:type=>:string/:proc},{}]
		@procedures=[];
	end ##}}}
	# :proc->internal cmd, :extern->call open.capture3
	def type
		return @procedures[0][:type];
	end
	## add(p,t), description
	# support type: 
	# :extern -> external cmd
	# :proc -> block
	def add(e,t); ##{{{
		p={:exe=>e,:type=>t.to_sym};
		@procedures << p;
	end ##}}}
	def exe ##{{{
		e=@procedures[0][:exe]; t=@procedures[0][:type];
		return e;# if t==:proc;
		#return self.instance_eval e if t==:extern;
	end ##}}}
	## owner(o), for internal proc executing, to specify which object
	# will evaluate this proc.
	def owner(o); ##{{{
		puts "#{__FILE__}:(owner(o)) is not ready yet."
		@executor=o;
	end ##}}}
	## raw, return the raw string, only available for command type is :string
	#TODO
	def raw; ##{{{
	end ##}}}
	## isBuiltinCommand, description
	# return if the given command is of type :proc
	def isBuiltinCommand; ##{{{
		return false if @procedures.empty?;
		return true if @procedures[0][:type]==:proc;
		return false;
	end ##}}}
end
