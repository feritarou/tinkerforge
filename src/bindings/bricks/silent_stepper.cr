@[Link(
		ldflags: "#{__DIR__}/../../../obj/brick_silent_stepper.o"
	)]

lib LibTF
  alias SilentStepper = Entity

	# Creates the device object \c silent_stepper with the unique device ID \c uid and adds
	# it to the IPConnection \c ipcon.
	fun silent_stepper_create(
		silent_stepper : SilentStepper*,
		uid : LibC::Char*,
		ipcon : IPConnection*
	) : Void

	# Removes the device object \c silent_stepper from its IPConnection and destroys it.
	# The device object cannot be used anymore afterwards.
	fun silent_stepper_destroy(
		silent_stepper : SilentStepper*
	) : Void

	fun silent_stepper_enable(
		silent_stepper : SilentStepper*
	) : LibC::Int

	fun silent_stepper_disable(
		silent_stepper : SilentStepper*
	) : LibC::Int

	fun silent_stepper_is_enabled(
		silent_stepper : SilentStepper*,
		ret_enabled : LibC::Int*
	) : LibC::Int

	fun silent_stepper_enable_status_led(
		silent_stepper : SilentStepper*
	) : LibC::Int

	fun silent_stepper_disable_status_led(
		silent_stepper : SilentStepper*
	) : LibC::Int

	fun silent_stepper_is_status_led_enabled(
		silent_stepper : SilentStepper*,
		ret_enabled : LibC::Int*
	) : LibC::Int

	fun silent_stepper_set_current_position(
		silent_stepper : SilentStepper*,
		position : Int32
	) : LibC::Int

	fun silent_stepper_set_step_configuration(
		silent_stepper : SilentStepper*,
		step_resolution : UInt8,
		interpolation : LibC::Int
	) : LibC::Int

	fun silent_stepper_set_speed_ramping(
		silent_stepper : SilentStepper*,
		acceleration : UInt16,
		deacceleration : UInt16
	) : LibC::Int

	fun silent_stepper_get_speed_ramping(
		silent_stepper : SilentStepper*,
		ret_acceleration : UInt16*,
		ret_deacceleration : UInt16*
	) : LibC::Int

	fun silent_stepper_get_external_input_voltage(
		silent_stepper : SilentStepper*,
		ret_voltage : UInt16*
	)

	fun silent_stepper_get_driver_status(
		silent_stepper : SilentStepper*,
		ret_open_load : UInt8*,
		ret_short_to_ground : UInt8*,
		ret_over_temperature : UInt8*,
		ret_motor_stalled : LibC::Int*,
		ret_actual_motor_current : UInt8*,
		ret_full_step_active : LibC::Int*,
		ret_stallguard_result : UInt8*,
		ret_stealth_voltage_amplitude : UInt8*
	) : LibC::Int

	fun silent_stepper_set_max_velocity(
		silent_stepper : SilentStepper*,
		velocity : UInt16
	) : LibC::Int

	fun silent_stepper_get_max_velocity(
		silent_stepper : SilentStepper*,
		ret_velocity : UInt16*
	) : LibC::Int

	fun silent_stepper_get_current_velocity(
		silent_stepper : SilentStepper*,
		ret_velocity : UInt16*
	) : LibC::Int

	fun silent_stepper_drive_forward(
		silent_stepper : SilentStepper*
	) : LibC::Int

	fun silent_stepper_drive_backward(
		silent_stepper : SilentStepper*
	) : LibC::Int

	fun silent_stepper_stop(
		silent_stepper : SilentStepper*
	) : LibC::Int

	fun silent_stepper_full_brake(
		silent_stepper : SilentStepper*
	) : LibC::Int

	fun silent_stepper_reset(
		silent_stepper : SilentStepper*
	) : LibC::Int

	SILENT_STEPPER_STEP_RESOLUTION_1 = 8
	SILENT_STEPPER_STEP_RESOLUTION_2 = 7
	SILENT_STEPPER_STEP_RESOLUTION_4 = 6
	SILENT_STEPPER_STEP_RESOLUTION_8 = 5
	SILENT_STEPPER_STEP_RESOLUTION_16 = 4
	SILENT_STEPPER_STEP_RESOLUTION_32 = 3
	SILENT_STEPPER_STEP_RESOLUTION_64 = 2
	SILENT_STEPPER_STEP_RESOLUTION_128 = 1
	SILENT_STEPPER_STEP_RESOLUTION_256 = 0

	SILENT_STEPPER_CALLBACK_UNDER_VOLTAGE = 40
	SILENT_STEPPER_CALLBACK_POSITION_REACHED = 41
	SILENT_STEPPER_CALLBACK_ALL_DATA = 47
	SILENT_STEPPER_CALLBACK_NEW_STATE = 48

	fun silent_stepper_register_callback(
		silent_stepper : SilentStepper*,
		callback_id : Int16,
		function : Void*,
		user_data : Void*
	) : Void

  SILENT_STEPPER_STATE_STOP = 1
  SILENT_STEPPER_STATE_ACCELERATION = 2
  SILENT_STEPPER_STATE_RUN = 3
  SILENT_STEPPER_STATE_DEACCELERATION = 4
  SILENT_STEPPER_STATE_DIRECTION_CHANGE_TO_FORWARD = 5
  SILENT_STEPPER_STATE_DIRECTION_CHANGE_TO_BACKWARD = 6

	fun silent_stepper_set_all_data_period(
		silent_stepper : SilentStepper*,
		period : UInt32
	) : LibC::Int

end
