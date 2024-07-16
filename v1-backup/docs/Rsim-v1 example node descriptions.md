# project of a uart ip
## root.rh
```ruby
rhload 'src/node'
```
## src/node.rh
```ruby
rhload 'rtl/node'
```
## src/rtl/node.rh
```ruby
component 'RhUart/rtl_lib/uart_rx/1.0' do

end
component 'RhUart/rtl_lib/uart_tx/1.0' do
end

design 'RhUart/rtl_lib/uart_top/1.0' do

end
```

## src/verify/node.rh

## src/meta/config/node.rh
## src/meta/design/node.rh
```ruby
design 'RhUart/ip_lib/uartip/1.0' do
	# design for uartip level, contains uart rtl and verify contents.
end
```