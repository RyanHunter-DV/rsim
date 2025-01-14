class Test < TestTemplate
	attr :template;
	## initialize(n), description
	def initialize(n,t) ##{{{
		@template=t.to_s;
		super(n,:test)
	end ##}}}

	## link(o), find template from o and link it
	def link(t,o) ##{{{
		case(t)
		when :template
			n=@template;
			@template=o.find(n,:template);
			Rsim.exception(NodeE,:reason=>"template(#{tn}) not exists in suite(#{o.id})") unless @template;
			Rsim.info("copy settings from template(#{@template.id})",9);
			_copy(@template);
		when :config
			n=@config;
			@config=o.find(n,:config);
			Rsim.exception(NodeE,:reason=>"config(#{tn}) not exists in suite(#{o.id})") unless @config;
		else
			Rsim.exception(NodeE,:reason=>"not support link for #{t}");
		end
	end ##}}}
	## _copy(t), copy settings from given template only when currently not set
	def _copy(t) ##{{{
		@config=t.config if @config==nil;
		@flow=t.flow if @flow==nil;
		args(t.args);
	end ##}}}
end
