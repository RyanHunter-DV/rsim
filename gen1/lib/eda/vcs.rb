"""
# Object description:
Eda, process commands for Vcs
"""
class Eda ##{{{
	
	attr_accessor :name;

	attr :step;
	attr :exe;

	attr :options;

	FORMATS={
		'define'   => '+define+<>',
		'filelist' => '-f <>',
		'timescale'=> '+timescale+<>',
		'64'       => '-full64',
	}

	## initialize(step), description
	def initialize(); ##{{{
		#puts "#{__FILE__}:(initialize(step)) is not ready yet."
		@name= 'VCS';
		@exe={
			:compile  => 'vlogan',
			:elaborate=> 'vcs'

		};
		if Rsim.ui.lsfenv?
			@exe.each_pair do |s,e|
				e.sub!(/^/,'bsub -Is ');
			end
		end
		@options={:compile=>[],:elaborate=>[],:sim=>[]};
	end ##}}}
	## prefixOfLsf, description
	def prefixOfLsf; ##{{{
		puts "#{__FILE__}:(prefixOfLsf) is not ready yet."
		
	end ##}}}
	## formatted(k,v), format the input string into given step type, and return true, or else return false.
	# str=[], will be like: 
	# ['64'] or
	# ['define','aaaa=bbbb']
	def formatted(str,step); ##{{{
		formatted=false;
		FORMATS.keys.each do |fk|
			if fk==str[0]
				fv=FORMATS[fk];
				if str.length>1
					@options[step.to_sym] << fv.sub(/\<\>/,v);
				else
					@options[step.to_sym] << fv;
				end
				formatted=true;
				break;
			end
		end
		return formatted;
	end ##}}}
	## parseCompileOptions(s), description
	def parseCompileOptions(strings); ##{{{
		strings.each do |str|
			splitted=str.split(' +');
			raise FatalE.new("unrecognizable eda compile string(#{str})") unless formatted(splitted,:compile);
		end
	end ##}}}
	## parseElaborateOptions(s), description
	def parseElaborateOptions(strings); ##{{{
		strings.each do |str|
			splitted=str.split(' +');
			raise FatalE.new("unrecognizable eda elaborate string(#{str})") unless formatted(splitted,:elaborate);
		end
	end ##}}}

	## command(step), return full command according to step
	def command(step); ##{{{
		cmd = @exe[step];
		@options[step].each do |opt|
			cmd += %Q| #{opt}|;
		end
		return cmd;
	end ##}}}
end ##}}}