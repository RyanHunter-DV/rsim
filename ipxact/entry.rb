$LOAD_PATH<<File.dirname(File.absolute_path(__FILE__));

require 'MetaData';
require 'IpxData';
require 'Config';

# load for chain required
require 'Generator';
require 'GeneratorExecutor';
require 'RsimFlow';


require 'Ipxact';

require 'tests/entry';

require 'Simulator';

$LOAD_PATH.delete(File.dirname(File.absolute_path(__FILE__)));
