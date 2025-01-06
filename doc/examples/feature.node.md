```ruby
# global feature
feature 'name', <default value>
component 'vlnv' do
	feature 'name', true # switch typed feature
	feature 'name2',<default value>
end

# config.node
config ... do
	feature 'name', true/false
	feature 'name', <value>
	feature 'inst.featurename', <value>
end
```