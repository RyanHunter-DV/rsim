"""
# Object description:
View, object type of component view
"""
require 'lib/nls/IpXactData.rb'
class View < IpXactData ##{{{
	
	attr :container;
	attr :fileSets;
	## initialize(id), description
	def initialize(id,c); ##{{{
		super(id);
		@container = c; # object of contained component.
		@fileSets=[]; # support multiple fileSets of one view
	end ##}}}

	## fileSet(n), specify the fileSet reference name,
	# will find out the object and record it
	def fileSet(n); ##{{{
		n=n.to_s;
		raise NodeE.new("fileSet(#{n}) not defined in its container component, pls declare fileSet first before view") unless @container.fileSets[:source].has_key?(n);
		@fileSets << @container.fileSets[:source][n];
	end ##}}}
end ##}}}