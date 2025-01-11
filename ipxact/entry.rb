$rsim_global_loadpath=File.dirname(File.absolute_path(__FILE__));
$LOAD_PATH<<$rsim_global_loadpath;

require 'MetaData';
require 'IpxData';
require 'Config';

# load for chain required
require 'Generator';
require 'GeneratorExecutor';
require 'RsimFlow';


require 'Ipxact';


$LOAD_PATH.delete($rsim_global_loadpath);
