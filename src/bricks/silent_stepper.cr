module TF

  # A Silent Stepper brick.
  class SilentStepperBrick < Device
    DEVICE_ID = 19

    # =======================================================================================
    # Constructor / destructor
    # =======================================================================================

    # Constructor is automatically generated

    def finalize
      # Make sure the stepper has been stopped before loosing contact
      LibTF.silent_stepper_stop ptr
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
      (enabled != 0)
    end

    # =======================================================================================
    # Basic configuration
    # =======================================================================================

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
      LibTF.silent_stepper_get_current_velocity ptr, out value
      value
    end

    # Sets the maximal velocity of the stepper motor in steps per second.
    def max_velocity=(value)
      LibTF.silent_stepper_set_max_velocity ptr, value
      value
    end

    # Returns the maximal velocity of the stepper motor in steps per second.
    def max_velocity
      LibTF.silent_stepper_get_max_velocity ptr, out value
      value
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
