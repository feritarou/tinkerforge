module TF

  # A [Rotary Poti Bricklet](https://www.tinkerforge.com/doc/Hardware/Bricklets/Rotary_Poti.html).
  #
  # ![Rotary Poti Bricklet](https://www.tinkerforge.com/doc/_images/Bricklets/bricklet_rotary_poti_tilted_800.jpg)
  class RotaryPotiBricklet < Bricklet
    include RegularCallback

    # =======================================================================================
    # Constants
    # =======================================================================================

    DEVICE_ID = 215

    # =======================================================================================
    # Properties
    # =======================================================================================

    # Returns the currently selected position on the poti in degrees.
    # Positions are returned as integer values in the range `-150..150`.
    def position
      if regular_callback? && (current_pos = @position)
        current_pos
      elsif attached? && LibTF.rotary_poti_get_position(ptr, out pos) == LibTF::E_OK
        @position = pos
        pos.not_nil!
      elsif p = @position
        p
      else
        0
      end.to_i32
    end

    # =======================================================================================
    # Instance variables
    # =======================================================================================

    @position : Int16?

    # =======================================================================================
    # Regular callback
    # =======================================================================================

    # :nodoc:
    def cb_position(pos)
      @position = pos
    end

    # =======================================================================================
    # Overrides
    # =======================================================================================

    private def register_regular_callback_function : Void*
      boxed = Box.box(->cb_position(Int16))
      LibTF.rotary_poti_register_callback(
        ptr, LibTF::ROTARY_POTI_CALLBACK_POSITION,
        Proc(Int16, Void*, Void).new do |position, user_data|
          cb = Box(Proc(Int16, Void)).unbox(user_data)
          cb.call(position)
        end.pointer,
        boxed \
      )
      boxed
    end

    private def set_regular_callback_period(period_in_milliseconds : UInt32)
      LibTF.rotary_poti_set_position_callback_period ptr, period_in_milliseconds
    end

  end
end
