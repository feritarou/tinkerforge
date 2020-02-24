module TF

  # A [Linear Poti Bricklet](https://www.tinkerforge.com/doc/Hardware/Bricklets/Linear_Poti.html).
  #
  # ![Linear Poti Bricklet](https://www.tinkerforge.com/en/doc/_images/Bricklets/bricklet_linear_poti_tilted_800.jpg)
  class LinearPotiBricklet < Bricklet
    include RegularCallback

    # =======================================================================================
    # Constants
    # =======================================================================================

    DEVICE_ID = 213

    # =======================================================================================
    # Properties
    # =======================================================================================

    # Returns the currently selected position on the poti in percents.
    # Positions are returned as integer values in the range `0..100`.
    def position
      if regular_callback? && (current_pos = @position)
        current_pos
      elsif attached? && LibTF.linear_poti_get_position(ptr, out pos) == LibTF::E_OK
        @position = pos
        pos.not_nil!
      elsif p = @position
        p
      else
        0u16
      end.to_i32
    end

    # =======================================================================================
    # Instance variables
    # =======================================================================================

    @position : UInt16?

    # =======================================================================================
    # Callbacks
    # =======================================================================================

    # :nodoc:
    def cb_position(pos)
      @position = pos
    end

    # =======================================================================================
    # Overrides
    # =======================================================================================

    private def set_regular_callback_period(period_in_milliseconds : UInt32)
      LibTF.linear_poti_set_position_callback_period ptr, period_in_milliseconds
    end

    private def register_regular_callback_function : Void*
      boxed = Box.box(->cb_position(UInt16))
      LibTF.linear_poti_register_callback(
        ptr, LibTF::LINEAR_POTI_CALLBACK_POSITION,
        Proc(UInt16, Void*, Void).new do |position, user_data|
          unboxed = Box(Proc(UInt16, Void)).unbox(user_data)
          unboxed.call(position)
        end.pointer,
        boxed \
      )
      boxed
    end

  end
end
