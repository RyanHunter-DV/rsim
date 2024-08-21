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

	## run(opts={}), called when running this generator
	def run(opts={}); ##{{{
		@options=opts;
		self.instance_eval &action;
	end ##}}}

	## exe(e), description
	# t==:find -> require which to find command path and check if it exists or not
	def exe(e); ##{{{
		if $OS==:Windows
			@exe = e;
		else
			cmd = "which #{e}";
			rst = Shell.exec(cmd,out: true);
			Rsim.info("getting out(#{rst[2]})",9);
			@exe= rst[2];
			raise FatalE.new("cannot find generator cmd(#{e}) by (#{cmd})") unless @exe and @exe!=' ';
		end
	end ##}}}
end ##}}}