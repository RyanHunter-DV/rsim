class TestSuite < IpxData

	attr :templates;
	attr :tests;
	
	## initialize(n), test suite name
	def initialize(n) ##{{{
		super(:id=>n.to_s,:ipxact=>:suite);	
		@templates={};@tests={};
	end ##}}}


	##### support commands {
	## template(n,&block), describe a new test template
	def template(n,&block) ##{{{
		t=TestTemplate.new(n);
		t.instance_eval &block;
		@templates[t.id]=t;
	end ##}}}
	## test(n,**opts,&block), describe a new test
	def test(n,**opts,&block) ##{{{
		Rsim.exception(NodeE,:reason=>"no template specified for test #{n}") unless opts.has_key?(:template);
		t=Test.new(n,opts[:template])
		t.instance_eval &block;
		@tests[t.id]=t;
	end ##}}}
	##### }

	## find(n), find template or test, according to the given name
	def find(n,t=:template) ##{{{
		n=n.to_s;
		if t==:template
			return @templates[n] if @templates.has_key?(n);
		else
			return @tests[n] if @tests.has_key?(n);
		end
		return nil; # not found
	end ##}}}

	## elaborate, change the template reference in every tests to template object
	def elaborate ##{{{
		@tests.each_value do |test|
			test.link(:template,self);
		end
		@tests.each_value do |test|
			test.link(:config,Rsim.ipxact);
		end
	end ##}}}

	## finalize, calling finalize of different templates reference and tests reference
	def finalize ##{{{
	end ##}}}
end
