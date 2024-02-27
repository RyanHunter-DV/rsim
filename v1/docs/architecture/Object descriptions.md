# Generator
The generator object, stores information of each generator description.
Multiple generators with a specified selector command can arrange a generator chain. Call of the group name or the root generator of the chain can start running the generator like a chain.
ref: [[Generator]]
**parameter setting and override**
parameter set in config > parameter set in component > parameter set at generator declare.
# Component
The object used to declare an IP-XACT component object, with user definitions in a code block, like: 
`component 'vlnv' do block end`
