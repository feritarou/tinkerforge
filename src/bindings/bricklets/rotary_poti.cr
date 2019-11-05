@[Link(
		ldflags: "#{__DIR__}/../../../obj/bricklet_rotary_poti.o"
	)]

lib LibTF
  # Creates the device object \c rotary_poti with the unique device ID \c uid and adds
  # it to the IPConnection \c ipcon.
  fun rotary_poti_create(
    rotary_poti : RotaryPoti*,
    uid : LibC::Char*,
    ipcon : IPConnection*
  ) : Void

  # Removes the device object \c rotary_poti from its IPConnection and destroys it.
  # The device object cannot be used anymore afterwards.
  fun rotary_poti_destroy(
    rotary_poti : RotaryPoti*
  ) : Void

  # Returns the position of the rotary potentiometer. The value is in degree
  # and between -150° (turned left) and 150° (turned right).
  # If you want to get the position periodically, it is recommended to use the
  # {@link ROTARY_POTI_CALLBACK_POSITION} callback and set the period with
  # {@link rotary_poti_set_position_callback_period}.
  fun rotary_poti_get_position(
    rotary_poti : RotaryPoti*,
    ret_position : Int16*
  ) : LibC::Int
end
