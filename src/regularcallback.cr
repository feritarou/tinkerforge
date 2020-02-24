module TF

  # :nodoc:
  protected class_property regular_callback_pointers = {} of UInt64 => Void*

  # Include this module in any brick/bricklet class that makes use of callbacks for data updates at regular intervals.
  module RegularCallback

    # =======================================================================================
    # Constants
    # =======================================================================================

    NONE = Time::Span::ZERO

    # =======================================================================================
    # Class variables
    # =======================================================================================



    # =======================================================================================
    # Properties
    # =======================================================================================

    # Returns `true` iff a regular data callback is configured for the device.
    def regular_callback?
      !regular_callback_interval.zero?
    end

    # Returns the regular data callback interval for the device,
    # or `NONE` if regular callbacks are switched off (default).
    getter regular_callback_interval = NONE

    # Sets the regular data callback interval for the device.
    # If it is set to `NONE`, regular callbacks are switched off (default).
    def regular_callback_interval=(value : Time::Span)
      if value != @regular_callback_interval
        set_cb_interval to: value
        if value.zero? && TF.regular_callback_pointers.has_key? object_id
          TF.regular_callback_pointers.delete object_id
        end
        @regular_callback_interval = value
      end
    end

    # =======================================================================================
    # Virtual functions
    # =======================================================================================

    # Override this function in any including type to call the appropriate callback period setter function in LibTF. Example usage from the RotaryPotiBricklet implementation:
    # ```
    # private def set_regular_callback_period(period_in_milliseconds : UInt32)
    #   LibTF.rotary_poti_set_position_callback_period ptr, period_in_milliseconds
    # end
    # ```
    abstract def set_regular_callback_period(period_in_milliseconds : UInt32)

    # Override this function in any including type to call the appropriate callback registration function in LibTF and return the boxed function pointer so it can be stored in a class variable. Example usage from the RotaryPotiBricklet implementation:
    # ```
    # # This function will be called as regular callback.
    # def cb_position(position : Int16)
    #   @position = position
    # end
    #
    # private def register_regular_callback_function : Void*
    #   boxed = Box.box(->cb_position(Int16))
    #   LibTF.rotary_poti_register_callback(
    #     ptr, LibTF::ROTARY_POTI_CALLBACK_POSITION,
    #     Proc(Int16, Void*, Void).new do |position, user_data|
    #       unboxed = Box(Proc(Int16, Void)).unbox(user_data)
    #       unboxed.call(position)
    #     end.pointer,
    #     boxed \
    #   )
    #   boxed
    # end
    # ```
    abstract def register_regular_callback_function : Void*

    # =======================================================================================
    # Overrides
    # =======================================================================================

    protected def configure
      set_cb_interval to: @regular_callback_interval
    end

    def detach
      set_cb_interval to: NONE
      super
    end

    # =======================================================================================
    # Helper functions
    # =======================================================================================

    private def set_cb_interval(to interval)
      if interval == NONE
        set_regular_callback_period 0u32
      else
        set_regular_callback_period 0u32
        boxed = register_regular_callback_function
        TF.regular_callback_pointers[object_id] = boxed
        set_regular_callback_period interval.total_milliseconds.to_u32
      end
    end

  end

end
