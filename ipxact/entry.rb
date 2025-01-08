$rsim_global_loadpath=File.dirname(File.absolute_path(__FILE__));
$LOAD_PATH<<$rsim_global_loadpath;

require '.rb'

$LOAD_PATH.delete($rsim_global_loadpath);
