# How to customize a user step for existing flow
#project/infra/rsim
Users can add their custom steps for an existing flow by building a node.rh file in `src/meta/flows` dir, and use rhload by the Tool's node loading step.
Examples:
```ruby
# src/meta/flows/buildflow.rh
flow :buildflow do
	step :pre_build do
		action :proc do
			puts "adding a custom pre_build step for buildflow"
		end
	end
end
```