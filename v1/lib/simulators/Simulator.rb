require 'lib/simulators/Xcelium'
class Simulator
	attr :eda;

	def initialize(edaType)
		p="#{edaType}.new();";
		@eda = self.instance_eval p;
	end

	## eda(t=:name), return eda, according to given t, return different type.
	# if t==:name (by default), return eda name.
	# else if t==:object, return eda object.
	def eda(t=:name) ##{{{
		return @eda.name if t==:name;
		return @eda if t==:object;
	end ##}}}

	## compopts(*args), set options for compile step, if eda has no this step, then ignore it.
	def compopts(*args) ##{{{
		return unless @eda.steps(:build).include?(:compile);
		@eda.addOptions(:compile,*args);
	end ##}}}
	## elabopts(*args), similar with the compopts
	def elabopts(*args) ##{{{
		return unless @eda.steps(:build).include?(:elab);
		@eda.addOptions(:elab,*args);
	end ##}}}
	## simopts(*args), similar with the compopts
	def simopts(*args) ##{{{
		return unless @eda.steps(:run).include?(:sim);
		@eda.addOptions(:sim,*args);
	end ##}}}

end
