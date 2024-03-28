# Dispatcher Sketch file
#project/infra/rsim
This doc page can be imported easily to the Bear app, which is the central doc collection for all projects.
```ruby
Dispatcher.schedule(step.action) # step is build, command is 'Rsim.generator.run'
# in Dispatcher:
if (cmd.isBuiltinCommand)
	cmd.procedures.each do |p|
		th= Thread.new() {
			self.instance_eval p
		}
		# or use fork
else
	out,err,state=open3.capture(step.command)
end

# call Rsim.generator.run
# in GeneratorChainTop.run
MetaData.config(:Config).components.each do |c|
	@dispatcher.schedule('build',:executor=>c)
end
```