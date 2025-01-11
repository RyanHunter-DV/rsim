"""
# Object description:
RegBlock, register block 
"""
require 'ipxact/IpxData.rb'
class RegBlock < IpxData
	attr :__ba__; # base address
	attr :__files__;
	attr :__regs__;

	attr :__c__; # the container of this regblock

	## initialize(id), description
	def initialize(id,c); ##{{{
		super(:id=>id,:ipxact=>:regblock);
		@__ba__ =0x0;
		@__regs__ = {};
		@__c__=c;
	end ##}}}

	## container(c), description
	def container(c) ##{{{
		@__c__=c;
	end ##}}}

	# support commands
	## reg(name,offset,&block), description
	def reg(name,offset,&block); ##{{{
		#puts "#{__FILE__}:start reg(name,offset,&block) ..."
		r=Register.new(name,self);
		r.offset(offset);
		r.instance_eval &block;
		@__regs__[r.id] = r;
	end ##}}}
	## base(addr), hex value of address
	def base(addr=nil); ##{{{
		#puts "#{__FILE__}:start base(addr) ..."
		return @__ba__ unless addr;
		@__ba__ = addr;
	end ##}}}
	## regFile(fn), specify register file name, support multiple files
	def regFile(*fns); ##{{{
		#puts "#{__FILE__}:start regFile(fn) ..."
		fns.each do |fn|
			# load and execute register files directly
			parseRegFile(fn);
		end
	end ##}}}

	## display, description
	def display; ##{{{
		puts "#{__FILE__}:start display ..."
		puts "type RegBlock";
		puts "- id: #{id}";
		puts "- reg files: ";
		@__regs__.each_value do |r|
			r.display;
		end
	end ##}}}

private
	## parseRegFile(fn), 
	# 1.check file existance
	# 2.read file contents
	# 3.self.instance_eval
	def parseRegFile(fn); ##{{{
		fn=File.join(@__c__.root,fn);
		if Rsim.os.fileExists?(fn)
			codes=Rsim.os.readfile(fn);
			self.instance_eval codes.join("\n");
		else
			Rsim.exception(NodeE,:reason=>"register file not exists #{fn}")
			#TODO, wait for execption Rsim.exception(NodeE,:reason => "register file #{fn} not exists");
		end
	end ##}}}
end

"""
# Object description:
Register, for register description
"""
class Register < IpxData
	attr :container;
	
	attr :__off__; ## offset
	attr :__fields__;
	## initialize(name,c), description
	def initialize(name,c); ##{{{
		super(:id=>name,:ipxact=>:register);
		@container=c;
		@__off__=0x0;
		@__fields__={};
	end ##}}}

	# support commands
	## offset(v), set offset value
	def offset(v); ##{{{
		#puts "#{__FILE__}:start offset(v) ..."
		@__off__=v;
	end ##}}}

	## field(name,acc,bitOffset,bits,reset), description
	def field(name,acc,bitOffset,bits,reset); ##{{{
		#puts "#{__FILE__}:start field(name,acc,bifOffset,bits,reset) ..."
		f=RegisterField.new(name,acc,bitOffset,bits,reset);
		@__fields__[f.id] = f;
	end ##}}}

	## display, description
	def display; ##{{{
		puts "#{__FILE__}:start display ..."
		puts "type Register";
		puts "- id: #{id}";
		puts "- offset: 0x#{__off__.to_s(16)}";
		@__fields__.each_value do |f|
			f.display;
		end
	end ##}}}
end

"""
# Object description:
RegisterField, descript the register field data
"""
class RegisterField < IpxData

	attr :__access__;
	attr :__bo__; # bit offset.
	attr :__rv__; # reset value
	attr :__width__;
	
	## initialize(name,acc,off,bits,v), description
	def initialize(name,acc,off,bits,v); ##{{{
		#puts "#{__FILE__}:start initialize(name,acc,off,bits,v) ..."
		super(:id=>name,:ipxact=>:registerField);
		access(acc);
		offset(off);
		width(bits);
		reset(v);
	end ##}}}
	## display, description
	def display; ##{{{
		puts "type RegisterField";
		puts "- id: #{id}";
		puts "- access: #{@__access__}";
		puts "- lsb: #{@__bo__}";
		puts "- width: #{@__width__}";
		puts "- reset value: #{@__rv__}";
	end ##}}}

private
	## access(a), 
	# if a invalid, set default access type.
	def access(a); ##{{{
		#puts "#{__FILE__}:start access(a) ..."
		@__access__ = 'RW' 
		@__access__ = a.to_s unless (a==nil or a=='');
	end ##}}}
	## offset(v), set bits offset
	def offset(v); ##{{{
	#	puts "#{__FILE__}:start offset(v) ..."
		@__bo__= 0;
		@__bo__= v unless v==nil;
	end ##}}}
	## width(v), description
	def width(v); ##{{{
		#puts "#{__FILE__}:start width(v) ..."
		@__width__=1;
		@__width__=v unless (v==nil or v<=0);
	end ##}}}
	## reset(v), description
	def reset(v); ##{{{
		#puts "#{__FILE__}:start reset(v) ..."
		@__rv__=0;
		@__rv__=v unless v==nil or v<0;
	end ##}}}
end
