@[Link(
		ldflags: "#{__DIR__}/../../../obj/bricklet_linear_poti.o"
	)]

lib LibTF
	alias LinearPoti = Entity

  # Creates the device object \c linear_poti with the unique device ID \c uid and adds
  # it to the IPConnection \c ipcon.
  fun linear_poti_create(
    linear_poti : LinearPoti*,
    uid : LibC::Char*,
    ipcon : IPConnection*
  ) : Void

  # Removes the device object \c linear_poti from its IPConnection and destroys it.
  # The device object cannot be used anymore afterwards.
  fun linear_poti_destroy(
    linear_poti : LinearPoti*
  ) : Void

	# Returns the position of the linear potentiometer. The value is between 0 (slider down) and 100 (slider up).
	#
	# If you want to get the position periodically, it is recommended to use the {@link LINEAR_POTI_CALLBACK_POSITION} callback and set the period with {@link linear_poti_set_position_callback_period}.
  fun linear_poti_get_position(
    linear_poti : LinearPoti*,
    ret_position : Int16*
  ) : LibC::Int

	fun linear_poti_set_position_callback_period(
		linear_poti : LinearPoti*,
		period : UInt32
	) : LibC::Int

	LINEAR_POTI_CALLBACK_POSITION = 13
	
	fun linear_poti_register_callback(
		linear_poti : LinearPoti*,
		callback_id : Int16,
		function : Void*,
		user_data : Void*
	) : Void
end
