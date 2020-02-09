module TF

  # A [Silent Stepper Brick](https://www.tinkerforge.com/doc/Hardware/Bricks/Silent_Stepper_Brick.html).
  #
  # ![Silent Stepper Brick](https://www.tinkerforge.com/doc/_images/Bricks/brick_silent_stepper_tilted_800.jpg)
  class SilentStepperBrick < Brick
    include RegularCallback

    DEVICE_ID = 19

    # =======================================================================================
    # Enums
    # =======================================================================================

    enum StepResolution : UInt8
      Full = 8
      Half = 7
      One4th = 6
      One8th = 5
      One16th = 4
      One32th = 3
      One64th = 2
      One128th = 1
      One256th = 0
    end

    # enum State : UInt8
    #   Stop = 1
    #   Acceleration = 2
    #   Run = 3
    #   Deacceleration = 4
    #   DirectionChangeToForward = 5
    #   DirectionChangeToBackward = 6
    # end
    #
    # @current_state : State? = nil
    #
    # def current_state : State
    #   if @current_state.nil?
    #     boxed_self = Box.box(self)
    #
    #     LibTF.silent_stepper_register_callback(
    #       ptr,
    #       LibTF::SILENT_STEPPER_CALLBACK_NEW_STATE,
    #       Proc(UInt8, UInt8, Void*, Void).new do |state_new, state_previous, user_data|
    #         instance = Box(self).unbox(user_data).as(SilentStepperBrick)
    #         instance.new_state(state_new, state_previous)
    #       end.pointer,
    #       boxed_self \
    #     )
    #
    #     @@boxed_self = boxed_self
    #
    #     State::Stop
    #   else
    #     @current_state.not_nil!
    #   end
    # end
    #
    #
    # # :nodoc:
    # def new_state(state_new, state_previous)
    #   @current_state = State.new(state_new)
    # end

    # =======================================================================================
    # Properties
    # =======================================================================================

    def step_resolution=(step_res : StepResolution)
      LibTF.silent_stepper_set_step_configuration ptr, step_res.value, 1
    end

    # =======================================================================================
    # Instance variables
    # =======================================================================================

    @current_velocity = 0

    # =======================================================================================
    # Callbacks
    # =======================================================================================

    # :nodoc:
    def all_data(current_velocity, current_position, remaining_steps, stack_voltage, external_voltage, current_consumption)
      @current_velocity = current_velocity.to_i32
    end

    # =======================================================================================
    # Constructor / destructor
    # =======================================================================================

    # Constructor is auto-generated

    def finalize
      # Make sure the stepper has stopped/reset before loosing contact
      LibTF.silent_stepper_reset ptr
      LibTF.silent_stepper_destroy ptr
    end

    # =======================================================================================
    # Enabling / disabling the driver
    # =======================================================================================

    # Enables the driver.
    def enable
      LibTF.silent_stepper_enable ptr
    end

    # Disables the driver.
    # By itself, this function does not change anything in the motor configuration, thus it is possible for the motor to keep on driving while disabling programmed control.
    def disable
      LibTF.silent_stepper_disable ptr
    end

    # Returns `true` if the driver is enabled, and `false` otherwise.
    def enabled?
      LibTF.silent_stepper_is_enabled ptr, out enabled
      (enabled == 0)
    end

    # =======================================================================================
    # Data access mode
    # =======================================================================================

    getter regular_callback_interval = Time::Span.zero

    def regular_callback_interval=(value : Time::Span)
      @regular_callback_interval = value

      if value.zero?
        @@callback_pointers.delete object_id
        LibTF.silent_stepper_set_all_data_period ptr, 0u32
      else
        boxed = Box.box(->all_data(UInt16, Int32, Int32, UInt16, UInt16, UInt16))

        LibTF.silent_stepper_register_callback(
          ptr, LibTF::SILENT_STEPPER_CALLBACK_ALL_DATA,
          Proc(UInt16, Int32, Int32, UInt16, UInt16, UInt16, Void*, Void).new \
          do |current_velocity, current_position, remaining_steps, stack_voltage, external_voltage, current_consumption, user_data|
            unboxed = Box(Proc(UInt16, Int32, Int32, UInt16, UInt16, UInt16, Void)).unbox(user_data)
            unboxed.call(current_velocity, current_position, remaining_steps, stack_voltage, external_voltage, current_consumption)
          end.pointer,
          boxed \
        )

        @@callback_pointers[object_id] = boxed
        LibTF.silent_stepper_set_all_data_period ptr, value.total_milliseconds.to_u32
      end
    end

    # =======================================================================================
    # Basic configuration
    # =======================================================================================

    # Resets the stepper motor.
    def reset
      LibTF.silent_stepper_reset ptr
    end

    # Returns the acceleration of the stepper motor in steps per s².
    # The default value is 1000 steps/s².
    def acceleration
      LibTF.silent_stepper_get_speed_ramping ptr, out a, out d
      a
    end

    # Sets the acceleration of the stepper motor in steps per s².
    # The default value is 1000 steps/s².
    def acceleration=(value)
      LibTF.silent_stepper_set_speed_ramping ptr, value, deacceleration
      value
    end

    # Returns the deacceleration of the stepper motor in steps per s².
    # The default value is 1000 steps/s².
    def deacceleration
      LibTF.silent_stepper_get_speed_ramping ptr, out a, out d
      d
    end

    # Sets the deacceleration of the stepper motor in steps per s².
    # The default value is 1000 steps/s².
    def deacceleration=(value)
      LibTF.silent_stepper_set_speed_ramping ptr, acceleration, value
      value
    end

    # =======================================================================================
    # Velocity control
    # =======================================================================================

    # Returns the current velocity of the stepper motor in steps per second.
    def current_velocity
      if @regular_callback_interval.zero?
        LibTF.silent_stepper_get_current_velocity ptr, out value
        value.to_i32
      else
        @current_velocity
      end
    end

    # Sets the maximal velocity of the stepper motor in steps per second.
    def max_velocity=(value)
      LibTF.silent_stepper_set_max_velocity ptr, value.to_u16
      value
    end

    # Returns the maximal velocity of the stepper motor in steps per second.
    def max_velocity
      LibTF.silent_stepper_get_max_velocity ptr, out value
      value.to_i32
    end

    # =======================================================================================
    # Driving
    # =======================================================================================

    enum Direction
      Forward, Backward
    end

    # Causes the motor to drive towards the specified *direction*.
    def drive(direction = Direction::Forward)
      case direction
      when .forward?
        LibTF.silent_stepper_drive_forward ptr
      when .backward?
        LibTF.silent_stepper_drive_backward ptr
      end
    end

    # Stops the motor.
    def stop
      LibTF.silent_stepper_stop ptr
    end

    # Emergency-stops the motor.
    # NOTE: This function should only be called in case of an emergency. Use `#stop` to stop the motor in all other cases.
    def full_brake
      LibTF.silent_stepper_full_brake ptr
    end

    # =======================================================================================
    # Driver status
    # =======================================================================================

    # Enables or disables the brick's status LED.
    def status_led_enabled=(enable)
      if enable
        LibTF.silent_stepper_enable_status_led ptr
      else
        LibTF.silent_stepper_disable_status_led ptr
      end
      enable
    end

    # Returns `true` if the brick's status LED is switched on and `false` otherwise.
    def status_led_enabled?
      LibTF.silent_stepper_is_status_led_enabled ptr, out enabled
      (enabled != 0)
    end

    # ---------------------------------------------------------------------------------------

    # Returns `true` if the motor is detected to be blocking.
    def stalled?
      LibTF.silent_stepper_get_driver_status ptr, out open_load, out short_to_ground, out over_temperature, out stalled, out actual_current, out full_step_active, out stallguard_result, out stealth_voltage_amplitude
      (stalled != 0)
    end

    # Returns a value that can be used to detect potential stalling dangers: The lower the stallguard result, the higher the load on the stepper motor, the higher the risk of stalls.
    def stallguard_result
      LibTF.silent_stepper_get_driver_status ptr, out open_load, out short_to_ground, out over_temperature, out stalled, out actual_current, out full_step_active, out stallguard_result, out stealth_voltage_amplitude
      stallguard_result
    end
  end
end
