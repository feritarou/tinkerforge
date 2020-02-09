@[Link(
		ldflags: "#{__DIR__}/../../../obj/bricklet_line.o"
	)]

lib LibTF
	alias Line = Entity

  # Creates the device object \c line with the unique device ID \c uid and adds
  # it to the IPConnection \c ipcon.
  fun line_create(
    line : Line*,
    uid : LibC::Char*,
    ipcon : IPConnection*
  ) : Void

  # Removes the device object \c line from its IPConnection and destroys it.
  # The device object cannot be used anymore afterwards.
  fun line_destroy(
    line : Line*
  ) : Void

  # Returns the currently measured reflectivity. The reflectivity is a value between 0 (not reflective) and 4095 (very reflective).
  #
  # Usually black has a low reflectivity while white has a high reflectivity.
  #
  # If you want to get the reflectivity periodically, it is recommended to use the LINE_CALLBACK_REFLECTIVITY callback and set the period with line_set_reflectivity_callback_period().
  fun line_get_reflectivity(
    line : Line*,
    ret_reflectivity : Int16*
  ) : LibC::Int

	LINE_CALLBACK_REFLECTIVITY = 8
	LINE_CALLBACK_REFLECTIVITY_REACHED = 9

	fun line_register_callback(
		line : Line*,
		callback_id : Int16,
		function : Void*,
		user_data : Void*
	) : Void

	fun line_set_reflectivity_callback_period(
		line : Line*,
		period : UInt32
	) : LibC::Int

	fun line_set_reflectivity_callback_threshold(
		line : Line*,
		option : LibC::Char,
		min : UInt16,
		max : UInt16
	) : LibC::Int

	fun line_set_debounce_period(
		line : Line*,
		debounce : UInt32
	) : LibC::Int
end
