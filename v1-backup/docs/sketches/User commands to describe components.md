# User commands to describe components
#project/infra/rsim/nodes

reference:
- [[Component description]]
- [[model of component]]

## generator
### Examples to use a generator in component

```ruby
component 'vlnv' do
	model do
		view 'name' do
			param :pname=>'defaultValue'
			# options specified in generator of the component will be defaultFileBuilder key.
			generator 'name', :option0=>'value',:option1=>@pname,...
		end
	end
end
```
#### Specify a generator by the generator name
generator is specified to be used according to the 'name' argument, which shall be pre-defined in global generator definition command.
#### Specify fixed value or a component parameter
Then coming with a hash that can specify user customized option values. The value can be a fixed value with string, int or other types suit for option.
And also, a pre-defined parameter can be specified as a generator option.

## param
Define component parameters.
ref: [[view of component]]
### Examples
```ruby
component 'vlnv' do
	model do
		view 'name' do
			param :p0=>'default value',:p1=>2,...
		end
		view 'name1' do
			param ...
		end
	end
end
```

## busInterface
To specify busInterfaces that used by this component,
with format `busInterface <busRef>,<absRef>`.
- The busRef is a busDefinition name which defined in global.
- The absRef is the abstractionDefinition name which defined in global, *this is optional arg*.

## model
#TBD 
Will create a ruby::ComponentModel type.
### Examples
```ruby
component 'vlnv' do
	model do
		port ... # describe different ports for this model.
		view ... # describe different views.
	end
end
```

## fileSet
