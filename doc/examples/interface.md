This example page has busDefinition and abstractionDefinition examples listed.

# how to build interfaces for a vip package?
- [x] does the vip package requires a standalone interface sv file or the interface can be built from a interface lib node?
standard interface can be used for dv or design, so I will declare a busDefinition or abstractionDefinition in interface lib and which can be used by projects, like:
```ruby
# interfaces/src/amba/node.rh
bus 'RH/interfaces/axi4/1.0' do
	maxMasters 16
	maxSlaves 16
end
abstraction 'RH/interfaces/axi4/1.0' do ##{{{
	bus 'RH/interfaces/axi4/1.0'
	param :ADDR_WIDTH=>32,:DATA_WIDTH=>32
	wire 'ACLK', :clock do
		onSystem :direction=>:in
		onMaster :direction=>:in
		onSlave  :direction=>:in
	end
	wire 'ARESETN',:data do
		onSystem :direction=>:in
		onMaster :direction=>:in
		onSlave  :direction=>:in
	end
	aChannel = {
		'ADDR'  => [:address,{:direction=>:in,:width=> :ADDR_WIDTH}],
		'VALID' => [:data,{:direction=>:in,:width=>1}],
		'PROT'  => [],
		'USER'  => [],
		...
	}
	aChannel.each_pair do |n,vs|
		wire "AW#{n}",vs[0] do
			opts={};
			vs[1].each_pair do |k,v|
				opts[k]=v;
			end
			onMaster **opts
			if (opts[:direction]==:in)
				opts[:direction]=:out;
			else
				opts[:direction]=:in;
			end
			onSlave **opts
		end
		wire "AR#{n}",vs[0] do
			...
		end
	end
	#wire 'AWADDR',:address do
	#	onMaster :direction => :in, :width => :ADDR_WIDTH
	#	onSlave :direction => :out, :width => :ADDR_WIDTH
	#end
end ##}}}
```
For DV usage, the above node can be analyzed and used to generate interface.sv files; while for RTL usage, it can be used to build a specific module port declaration.
- [ ] need think on how to build port declarations for a certain RTL.