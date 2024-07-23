"""
# Object description:
Step, call and run actions
"""
require 'lib/nls/IpXactData.rb'
class Step < IpXactData ##{{{
	attr :action;
	attr :options;
	## initialize(id,&block), description
	def initialize(id,&block); ##{{{
		super(id);
		@action = block;
		@options={};
	end ##}}}

	## run(**opts), description
	def run(opts); ##{{{
		Rsim.info("run step(#{@id}) with options (#{opts})",9)
		@options=opts;
		if @action.is_a?(Proc)
			self.instance_exec &@action;
		else
			Rsim.error("step(#{@id} has no action(#{@action}))");
		end
	end ##}}}
end ##}}}