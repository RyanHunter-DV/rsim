class GenRef
	attr :name;
	attr :block;
	attr :type;

	attr :generator;
	attr :parent;


	attr_accessor :params;

	def initialize(name,o,c,opts={})
		@name=name.to_s;
		@type = opts.delete(:type);
		@opts = opts;
		@params = {};
		@generator = o;
		@parent= c;
	end

	def name(name=nil)
		return @name if name.nil?;
		@name=name.to_s;
	end

	def method_missing(method_name, *args, &block)
		RsApp.info("method_missing: #{method_name}, call from generator: #{@generator.name}", 5)
		@generator.send(method_name.to_sym, *args, &block)
	end

	def param(opts={})
		@params.merge!(opts);
	end
	def phase
		return @generator.phase;
	end
	def chain
		return @parent;
	end

end
class GeneratorChain

	attr_accessor :name;

	attr :params; # params from ui(cmdline or env).
	attr :generators;
	attr :chain_selectors;
	attr :args;
	def initialize(name,opts={})
		@name=name;
		@opts=opts;
		@generators={};
		@chain_selectors={};
		@args={};
	end
	# support commands as below, the commands will be executed while the chain's execute is called.
	# generator, to specify a generator reference.
	# chain_sel 'name'
	def generator(name,opts={},&block)
		opts[:type]=:generator unless opts.has_key?(:type);
		g=RsApp.generator(name);
		raise IPXE, "Generator '#{name}' not found" if g.nil?;
		o=GenRef.new(name,g,self,opts);
		o.instance_eval(&block);
		register_genref(o,opts[:type]);
	end
	# chain_sel 'chain name' do
	# param xxx
	# end
	def chain_sel(name,opts={},&block)
		#@chain_selectors[name]=opts;
		opts[:type]=:chain unless opts.has_key?(:type);
		o=GenRef.new(name,self,opts);
		o.instance_eval(&block);
		register_genref(o,opts[:type]);
	end

	def arg(id,opts={})
		@args[id.to_sym]=opts;
	end


	def register_genref(o,type)
		if type==:chain
			@chain_selectors[o.name]=o;
		else
			@generators[o.name]=o;
		end
	end

	def traverse_chain()
		select_gens = {};
		if @chain_selectors.any?
			@chain_selectors.each do |selector_name, selector|
				# Get the chain from RsApp.chains
				c = RsApp.chain(selector_name)
				if c
					# Recursively deassemble the nested chain
					select_gens.merge!(c.traverse_chain)
				end
			end
		end
		select_gens.merge!(@generators);
		return select_gens;
	end

	def execute(params)
		#select_gens = @generators.values;
		select_gens=traverse_chain(); # genRef
		#TODO, need consider the phase of the generators.
		# Group generators by phase and execute them in order
		phases = select_gens.values.group_by(&:phase).keys.sort

		phases.each do |phase|
			RsApp.debug("Executing generators in phase #{phase}", 5)
			phase_gens = select_gens.values.select { |gen| gen.phase == phase }
			
			# Execute all generators in the same phase in parallel
			# if type is gen
			processes = [];
			phase_gens.each do |gen|
				p=params.merge(gen.params);
				processes << gen.execute(p)
			end
			
			# Wait for all jobs in this phase to complete before moving to next phase
			status=RsApp.mj.await(processes)
			RsApp.info("Status: #{status}", 1)
			failed_jobs = status.select { |job_id, job_status| job_status == :finished_on_error }
			if failed_jobs.any?
				failed_job_ids = failed_jobs.keys
				RsApp.info("Failed job IDs: #{failed_job_ids.join(', ')}", 1)
				raise Exception, "One or more generators in phase #{phase} failed with error"
			end
		end
	end
end