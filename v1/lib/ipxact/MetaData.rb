# The very top namespace of the IP-XACT meta database, this will be a common space for
# different user scopes to access some of the common data information, such as the design object.
# ----------------------------------------------------------------------------------------------
# Rsim.design -> the design object that created by user.
# Rsim.generators -> the hash stores all generator chain objects.
# ----------------------------------------------------------------------------------------------
module MetaData

	@design= nil;
	@generators={};

	# path stored.
	# [:components] => 'OUT/components'
	# [:ComponentName] => 'OUT/components/ComponentName'
	# [:configs] => 'OUT/configs'
	# [:ConfigName] => 'OUT/configs/ConfigName'
	@outs = {};

end