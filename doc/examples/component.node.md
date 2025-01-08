```ruby
component 'vendor/lib/name/version' do # the component name will be module name
	fileSet 'rtl0' do
		root 'root path of this fileSet'
		vs 'fifo.vsrc',:filelist => true # vs is for custom source.
		# sv, v
	end
	view 'viewname' do
		fileSet 'rtl0'
	end
end
```