#require 'node/ipxact/IpxData.rb'
require 'ipxact/Port.rb'
"""
# Object description:
WirePort, declare the Wire typed port information
Support the port command in component and abstractionDefinition.
"""
class WirePort < Port ##{{{
	attr :direction;
	attr_accessor :rsb;
	attr_accessor :lsb;

	# qualifier: :clock, :data, :address
	attr :__q__;
	attr :__container__; # :abstraction, :component
	attr :__views__;
	## initialize(name), description
	def initialize(name); ##{{{
		#puts "#{__FILE__}:start initialize(name) ..."
		super(name,:wire);
		# :in, :out, :inout, :net (default)
		@direction = :net;
		@rsb=0;@lsb=0;
		@__views__={:master=>{},:slave=>{},:system=>{}};
	end ##}}}

	## set(**opts), set options
	def set(**opts); ##{{{
		#puts "#{__FILE__}:start set(**opts) ..."
		opts[:rsb]=0 unless opts.has_key?(:rsb);
		opts[:lsb]=0 unless opts.has_key?(:lsb);
		opts[:type]=:data unless opts.has_key?(:type);

		direction(opts[:direction]);
		width(opts[:rsb],opts[:lsb]);
		@__q__=opts[:type];
	end ##}}}
	
	## usedBy(p), set container
	def usedBy(p); ##{{{
		@__container__ = p;
	end ##}}}
	## qualifier(q), description
	def qualifier(q); ##{{{
		@__q__=q.to_sym;
	end ##}}}
	##### node commands for abstraction {
	## onMaster(**opts), setting options for master view
	def onMaster(**opts); ##{{{
		m=@__views__[:master];
		opts.each_pair do |k,v|
			m[k]=v;
		end
		m[:width] = 1 unless m.has_key?(:width);
		m[:direction] = :in unless m.has_key?(:direction);
	end ##}}}
	def onSlave(**opts); ##{{{
		m=@__views__[:slave];
		opts.each_pair do |k,v|
			m[k]=v;
		end
		m[:width] = 1 unless m.has_key?(:width);
		m[:direction] = :in unless m.has_key?(:direction);
	end ##}}}
	def onSystem(**opts); ##{{{
		m=@__views__[:system];
		opts.each_pair do |k,v|
			m[k]=v;
		end
		m[:width] = 1 unless m.has_key?(:width);
		m[:direction] = :in unless m.has_key?(:direction);
	end ##}}}
	##### }



	## display, print internal database
	def display; ##{{{
		#puts "#{__FILE__}:start display ..."
		puts "type: WirePort"
		puts "- id: #{id}";
		puts "- direction: #{@direction}";
		puts "- vector: [#{@rsb}:#{@lsb}]";
		puts "- qualifier: #{@__q__}";
	end ##}}}

private
	## direction(d=nil), get or set the port direction
	def direction(d=nil); ##{{{
		#puts "#{__FILE__}:start direction(d=nil) ..."
		return @direction unless d;
		@direction = d;
	end ##}}}
	## width(rsb,lsb), set width
	def width(rsb,lsb); ##{{{
		#puts "#{__FILE__}:start width(rsb,lsb) ..."
		@rsb=rsb;@lsb=lsb;
	end ##}}}

end ##}}}