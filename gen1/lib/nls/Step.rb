"""
# Object description:
Step, call and run actions
"""
require 'lib/nls/IpXactData.rb'
class Step < IpXactData ##{{{
	attr :action;
	## initialize(id,&block), description
	def initialize(id,&block); ##{{{
		super(id);
		@action = block;
	end ##}}}
end ##}}}