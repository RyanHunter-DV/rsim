"""
# Object description:
Design, description
"""
require 'ipxact/IpxData.rb'
require 'ipxact/ComponentInstance.rb'
class Design < IpxData

	attr :__pool__;
	attr :__iname__; # instance name

	#[<string: instance name>] -> ComponentInstance object
	attr :instances;
	# connections[:bus] = {<src> => {to0=>block,to1=>block,...},<src2>=>{to0,to2,...}}
	# connections[:adhoc]
	attr :connections;
	
	# parent design if has
	attr_accessor :parent;

	## initialize(vlnv), description
	def initialize(vlnv,opts={}); ##{{{
		super(:id=>vlnv,:ipxact=>:design)
		@__iname__='design';
		@parent=nil;
		@instances={};
		@connections={:bus=>{},:adhoc=>{}};
	end ##}}}

	## fullname, return full hierarchical name
	def fullname; ##{{{
		#puts "#{__FILE__}:start fullname ..."
		h='';
		h= @parent.fullname+'.' if @parent;
		h+=@__iname__;
		return h;
	end ##}}}
	## mapping(&block), for register and memory mapping command
	#TODO,
	def mapping(&block); ##{{{
		#TODO, not ready yet.
	end ##}}}

	#============ support commands ============#
	## instance(vlnv,**opts), 
	# 1.search Component object in Database by given vlnv.
	# 2.create a new ComponentInstance object and store the search Component object information.
	# 3.build a method within this Design object so that direct instance reference can work, which will
	# return the ComponentInstance object.
	# 4.register the ComponentInstance into the Design object's pool
	# vlnv, gives the component object vlnv.
	# opts[:as], specify instance name
	def instance(vlnv,**opts); ##{{{
		Rsim.exception(NodeE,:reason=>"no ':as' option given for instantiating component: #{vlnv}") unless opts.has_key?(:as);
		as=opts[:as];
		ci=ComponentInstance.new(as,vlnv,self);
		_buildInstanceReference(as,ci);
		Rsim.info("building component instance #{vlnv} -> #{as}",9);
		@instances[as.to_s] = ci;
	end ##}}}

	## connect(type,**pairs), description
	def connect(type,**pairs,&block); ##{{{
		t=type.to_sym;
		_checkConnectType(type);
		case(t)
		when :bus
			pairs.each_pair do |src,to|
				src=src.to_s;to=to.to_s;
				_busConnect(src,to,block);
			end
		when :adhoc
			_adhocConnect(**pairs);
		end
	end ##}}}

	## elaborate, 
	# 1.all component instance shall be called to execute the elaborate
	#
	def elaborate; ##{{{
		evalNodes;
		@instances.each_pair do |name,ci|
			Rsim.info("elaborate instance #{name}",9)
			ci.elaborate;
		end
		@connections.each_pair do |ct,info|
			Rsim.info("elaborate #{ct} connections");
			info.each_pair do |src,tos|
				# message like: self.dv.dut_bus.connect
				#message=%Q|#{src}.connect|;
				splitted = src.split('.');
				c= self;
				splitted.each do |s|
					c=c.send(s.to_sym);
				end
				tos.each_pair do |to,b|
					c.send(:connect,to,b);
				end
			end
		end
	end ##}}}

	## finalize, call to dump metadata
	#def finalize ##{{{
	#	_dumpMetaData;
	#end ##}}}

private
	## _dumpMetaData, dump the config data information
#TODO, design has no outhome, so is it necessary to dump metadata?
	#def _dumpMetaData ##{{{
	#	#@metadata.record(:node,@root);
	#	@metadata.record(:outhome,@outhome);
	#	#@metadata.record(:design,@design.id);
	#	@metadata.record(:instances,{});
	#	@instances.each_pair do |n,o|
	#		@metadata.record(n,o.id,:instances);
	#	end
	#	@metadata.write(@outhome);
	#end ##}}}

	## _adhocConnect(**pairs), description
	def _adhocConnect(**pairs); ##{{{
		pairs.each_pair do |src,to|
			src=src.to_s;to=to.to_s;
			@connections[:adhoc][src]=[] unless @connections[:adhoc].has_key?(src);
			@connections[:adhoc][src] << to;
		end
	end ##}}}

	## _busConnect(src,to,block),
	def _busConnect(src,to,block); ##{{{
		bCnt=@connections[:bus];
		bCnt[src]={} unless bCnt.has_key?(src);
		block=nil unless block_given?;
		bCnt[src][to]=block;
	end ##}}}

	## _buildInstanceReference(name,o), description
	# let the Design object be able to invoke the component instance through
	# the instance name like: design.instname
	def _buildInstanceReference(name,o); ##{{{
		#puts "#{__FILE__}:start _buildInstanceReference(name,o) ..."
		self.define_singleton_method name.to_sym do ##{{{
			return o;
		end ##}}}
	end ##}}}

	## _checkConnectType(t), description
	def _checkConnectType(t); ##{{{
		return if t==:bus or t==:adhoc;
		Rsim.exception(NodeE,:reason=>"unsupport bus type #{t} in design connection");
	end ##}}}

end
