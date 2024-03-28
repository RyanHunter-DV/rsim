# Object for commands organizing and passing through the Rsim tool.
"""
# Object description:
Command, object used to store attributes and apis for a command
Which can be internal block, or external command string that can be operated
by this object
"""
class Command ##{{{

	#TODO, attr fields.
	attr :procedures;
	attr :scope;

	## initialize(p), description
	def initialize(s); ##{{{
		puts "#{__FILE__}:(initialize(p)) is not ready yet."
		@scope = s;
		# format:
		# [{:proc=>xxx,:type=>:string/:proc},{}]
		@procedures=[];
	end ##}}}
	## add(p,t), description
	# support type: 
	# :string,
	# :proc -> block
	# :exe -> external executor.
	def add(b,t); ##{{{
		if t.to_sym==:exe
			cmd= eval b;
			p={:proc=>cmd,:type=>t.to_sym};
		else
			p={:proc=>b,:type=>t.to_sym};
		end
		@procedures << p;
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
	# return if the given command has block or string type
	def isBuiltinCommand; ##{{{
		return false if @procedures.empty?;
		return true if @procedures[0][:type]==:proc;
		return false;
	end ##}}}
end ##}}}
