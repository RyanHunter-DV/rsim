The generator object, stores information of each generator description.
# Declare a user generator
Create a new Class extends from the Generator class, the new class type is named as the defined generator, like: `BuildFlow`.
# Use a declared generator


# Flow to create a new generator
1. define global generator method
2. call `g=Generator.new(name,Rsim.out[:build])`
3. eval block within new generator object.
# Flow to setup generator chain
1. User call like `buildflow(:Config).run`
2. call the root generator's setup API.
	1. setup exe command 


# Object architecture
## attr::execHome
The path that the .cmd file will be built and executed, this field is available for all Generator instances.
## command::exe
The exe command called while defining a new generator type, to specify the path and name of the generator's executor.



---
# sketch & examples
```ruby
generator 'BuildFlow' do
	root
	group 'build'
	transportMethod :SOAP
	selector 'BuildRtl',:phase=>0.0
	selector 'BuildVerify',:phase=>1.0
end
generator 'BuildRtl' do
	exe 'xxx'
	Rsim.design.components.each do |c|
		next if isNotRtlComponent
		if c.generator==nil
			selector 'BuildCopy',:target=>c,:phase=>0.0
		else
			selector c.generator,:target=>c,:phase=>c.generator.phase
		end
	end
end

generator 'BuildCopy' do
	exe '<path>/cp'
end
generator 'BuildLink' do
	exe '<path>/ln'
	parameter :SymbolLink,'-s',:priority=>0
end

component 'xxx' do
	generator 'BuildLink' do
		phase 0.1
	end
end

component 'xxx' do
	generator 'BuildCopy' do
		# option format: id,value,priority
		parameter :SrcPath,component.srcPath,:priority=>1
		parameter :TargetPath,component.buildPath,:priority=>2
		phase 0.2
	end
end
```