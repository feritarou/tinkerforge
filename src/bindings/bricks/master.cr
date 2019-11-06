@[Link(
		ldflags: "#{__DIR__}/../../../obj/brick_master.o"
	)]

lib LibTF
	alias Master = Entity

	# Creates the device object \c master with the unique device ID \c uid and adds
	# it to the IPConnection \c ipcon.
	fun master_create(
	  master : Master*,
	  uid : LibC::Char*,
	  ipcon : IPConnection*
	) : Void

	# Removes the device object \c master from its IPConnection and destroys it.
	# The device object cannot be used anymore afterwards.
	fun master_destroy(
	  master : Master*
	) : Void
end
