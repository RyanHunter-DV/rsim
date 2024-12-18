"""
# Object description:
Design, description
"""
require 'ipxact/IpxData.rb'
require 'ipxact/ComponentInstance.rb'
class Design < IpxData##{{{

	attr :__pool__;
	attr :__iname__; # instance name
	
	# parent design if has
	attr_accessor :parent;

	## initialize(vlnv), description
	def initialize(vlnv,opts={}); ##{{{
		#puts "#{__FILE__}:start initialize(vlnv) ..."
		super(:id=>vlnv)
		@__iname__='design';
		@parent=nil;
	end ##}}}

	## fullname, return full hierarchical name
	def fullname; ##{{{
		#puts "#{__FILE__}:start fullname ..."
		h='';
		h= @parent.fullname+'.' if @parent;
		h+=@__iname__;
		return h;
	end ##}}}

	# support commands
	## instance(vlnv,**opts), 
	# 1.search Component object in Database by given vlnv.
	# 2.create a new ComponentInstance object and store the search Component object information.
	# 3.build a method within this Design object so that direct instance reference can work, which will
	# return the ComponentInstance object.
	# 4.register the ComponentInstance into the Design object's pool
	def instance(vlnv,**opts); ##{{{
		#puts "#{__FILE__}:start instance(vlnv,**opts) ..."
		c=DataBase.find(vlnv,:component);
		Rsim.exception(NodeE,:reason=>"cannot find component: #{vlnv}") unless c;
		Rsim.exception(NodeE,:reason=>"no ':as' option given for instantiating component: #{vlnv}") unless opts.has_key?(:as);
		as=opts[:as];
		ci=ComponentInstance.new(as,c,self);
		_buildInstanceReference(as,ci);
	end ##}}}

	## connect(type,**pairs), description
	def connect(type,**pairs); ##{{{
		#puts "#{__FILE__}:start connect(type,**pairs) ..."
		message = type.to_s+"Connect";
		self.send(message,pairs);
	end ##}}}

	## busConnect(pairs), bus connecting
	def busConnect(pairs); ##{{{
		#puts "#{__FILE__}:start busConnect(pairs) ..."
		pairs.each do |o,c| # originator => consumer
			# the originator and consumer are objects of BusInterface, which is
			# not elaborated so which only has bus definition name stored.
			o.connect(c);
		end
	end ##}}}



private
	## _buildInstanceReference(name,o), description
	def _buildInstanceReference(name,o); ##{{{
		#puts "#{__FILE__}:start _buildInstanceReference(name,o) ..."
		self.define_singleton_method name.to_sym do ##{{{
			return o;
		end ##}}}
	end ##}}}


end ##}}}