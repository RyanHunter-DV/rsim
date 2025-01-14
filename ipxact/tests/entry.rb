
$LOAD_PATH<<File.dirname(File.absolute_path(__FILE__));

require 'TestSuite';
require 'TestTemplate';
require 'Test';

$LOAD_PATH.delete(File.dirname(File.absolute_path(__FILE__)));
