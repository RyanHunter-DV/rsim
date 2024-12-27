require 'ipxact/IpxData.rb'
require 'ipxact/View.rb'
require 'ipxact/FileSet.rb'
require 'ipxact/Generator.rb'
require 'ipxact/WirePort.rb'
require 'ipxact/registers.rb'

"""
# Object description:
Component, ip-xact concept object.
"""
class Component < IpxData ##{{{
	attr_accessor :root; # source home of this component desc file.
	attr_accessor :out; # out home of this component with publsihed intance

	attr :pool;
	attr :commands;
	attr :__isInst__;
	## initialize(name,opts={}), 
	# name is the vlnv name, opts is options which currently are reserved.
	def initialize(vlnv,opts={}); ##{{{
		#puts "#{__FILE__}:start initialize(name,opts={}) ..."
		super(:id=>vlnv);
		@pool={};
		@out={}; # :id=>path,...
		@commands=[];
		@__isInst__=false;
		@__isInst__=opts[:inst] if opts.has_key?(:inst);
		setRoot(caller(2)[0]) unless @__isInst__;
	end ##}}}

	## wire(name,direction,rsb,lsb), description
	def wire(name,d,rsb=0,lsb=0,**opts); ##{{{
		#puts "#{__FILE__}:start wire(name,direction,rsb,lsb) ..."
		w=WirePort.new(name);
		#w.direction(d);
		#w.width(rsb,lsb);
		opts[:rsb]=rsb;opts[:lsb]=lsb;
		opts[:direction]=d;
		w.set(**opts);
		register(w,:port,:command=>name);
	end ##}}}

	## view(name,&block), description
	# declare a new view description by node
	def view(name,&block); ##{{{
		#puts "#{__FILE__}:start view(name,&block) ..."
		#1.create a new ComponentView object.
		v=ComponentView.new(name);
		#2.eval block within the object,
		v.instance_eval &block;
		#which will have commands like fileSet, to specify reference
		#3.register the view object into this component
		register(v,:view,:command=>name);
	end ##}}}
	## views(id), 
	# return specified id of view, if id not specified, then return
	# all available views
	def views(id=nil); ##{{{
		#puts "#{__FILE__}:start views(id) ..."
		return nil unless @pool.has_key?(:view);
		return @pool[:view] unless id;
		return @pool[:view][id];
	end ##}}}
	## fileSet(name,&block), 
	# declare a new fileSet object
	def fileSet(name,&block); ##{{{
		#puts "#{__FILE__}:start fileSet(name,&block) ..."
		#1.create FileSet object.
		f=FileSet.new(name);
		#2.eval the object with given block.
		f.instance_eval &block;
		#3.register
		register(f,:fileSet);
	end ##}}}
	## regblock(name,&block), description
	def regblock(name,&block); ##{{{
		#puts "#{__FILE__}:start regblock(name,&block) ..."
		r=RegBlock.new(name,self);
		r.instance_eval &block;
		register(r,:regBlock);
	end ##}}}
	## generator(name,&block), 
	def generator(name,&block); ##{{{
		#puts "#{__FILE__}:start generator(name,&block) ..."
		g=ComponentGenerator.new(name);
		g.instance_eval &block;
		register(g,:generator,:command=>name);
	end ##}}}
	## bus(vlnv,**opts,&block), specify busInterface for this component
	def bus(vlnv,**opts,&block); ##{{{
		#puts "#{__FILE__}:start bus(vlnv,**opts,&block) ..."
		Rsim.exception(NodeE,:reason=>"require bus instance name") unless opts.has_key?(:as);
		b=BusInterface.new(opts[:as],vlnv);
		b.instance_eval &block; # execute setting information for busInterface.
		register(b,:busInterface,:command=>opts[:as]);
	end ##}}}

	## elaborate, description
	def elaborate; ##{{{
		#puts "#{__FILE__}:start elaborate ..."
		#TODO, 1 find busDefinition in database and store to Component
		@pool[:busInterface].each_value do |bo|
			bo.elaborate;
		end
	end ##}}}

	## print, print internal component data
	def display; ##{{{
		#puts "#{__FILE__}:start print ..."
		puts "type: Component";
		puts "- vlnv: #{id}"
		puts "- root: #{@root}";
		puts "- out: ";
		@out.each_pair do |i,p|
			puts "-- #{i} -> #{p}";
		end
		@pool.each_pair do |t,os|
			puts "-- #{t}";
			os.each_value do |o|
				o.display;
			end
		end
	end ##}}}

	## instance(o), called by the component instance, to copy
	# ipxact data information to it.
	def instance(o); ##{{{
		@pool.each_pair do |t,p|
			p.each_pair do |id,info|
				c=info[:object].copy;
				opts={};
				opts[:command]=info[:command] if info.has_key?(:command);
				opts[:hierarchy] = o.fullname;
				o.register(c,t,**opts);
			end
		end
		o.root=@root;
	end ##}}}

	## register(o,type), register given object into given type
	def register(o,type,**opts); ##{{{
		@pool[type] = {} unless @pool.has_key?(type);
		@pool[type][o.id] = {:object=>o};
		if (@__isInst__)
			# component instance register the bus/port need set the instance name
			o.hierarchy(opts[:hierarchy]) if type==:busInterface;
			o.hierarchy(opts[:hierarchy]) if type==:port;
		end
		if opts.has_key?(:command)
			@pool[type][o.id][:command]=opts[:command];
			_buildRefCommand(opts[:command],o);
		end
	end ##}}}
private

	## _buildRefCommand(c,o), description
	def _buildRefCommand(c,o); ##{{{
		#puts "#{__FILE__}:start _buildRefCommand(c,o) ..."
		c=c.to_sym;
		if @commands.include?(c)
			Rsim.exception(NodeE,:reason=>"reference command(#{c}) has been declared before");
			return;
		end
		@commands << c;
		self.define_singleton_method c do ##{{{
			return o;
		end ##}}}
	end ##}}}

	## setRoot(stack), to get the root path from stack info
	def setRoot(stack); ##{{{
		#puts "#{__FILE__}:start setRoot(stack) ..."
		splitted = stack.split(/:/);
		@root=File.dirname(File.absolute_path(splitted[0]));
	end ##}}}
end ##}}}