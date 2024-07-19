"""
# Object description:
Generator, description
"""
class Generator < IpXactData ##{{{
	attr :action;
	attr :options;
	attr :exe; # the executor
	## initialize(id), description
	def initialize(id,&block); ##{{{
		super(id);
		@action=block;
		@options={};
	end ##}}}

	## run(**opts), called when running this generator
	def run(**opts); ##{{{
		@options=opts;
		self.instance_eval &action;
	end ##}}}
end ##}}}