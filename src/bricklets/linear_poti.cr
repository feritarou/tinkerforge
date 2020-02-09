module TF

  # A [Linear Poti Bricklet](https://www.tinkerforge.com/doc/Hardware/Bricklets/Linear_Poti.html).
  #
  # ![Linear Poti Bricklet](https://www.tinkerforge.com/en/doc/_images/Bricklets/bricklet_linear_poti_tilted_800.jpg)
  class LinearPotiBricklet < Bricklet
    include RegularCallback

    DEVICE_ID = 213

    # =======================================================================================
    # Instance variables
    # =======================================================================================

    @position = 0u16

    # =======================================================================================
    # Callbacks
    # =======================================================================================

    # :nodoc:
    def cb_position(position)
      @position = position
    end

    # =======================================================================================
    # Data access mode
    # =======================================================================================

    getter regular_callback_interval = Time::Span.zero

    def regular_callback_interval=(value : Time::Span)
      @regular_callback_interval = value

      if value.zero?
        @@callback_pointers.delete object_id
        LibTF.linear_poti_set_position_callback_period ptr, 0u32
      else
        boxed = Box.box(->cb_position(UInt16))

        LibTF.linear_poti_register_callback(
          ptr, LibTF::LINEAR_POTI_CALLBACK_POSITION,
          Proc(UInt16, Void*, Void).new do |position, user_data|
            instance = Box(Proc(UInt16, Void)).unbox(user_data)
            instance.call(position)
          end.pointer,
          boxed \
        )

        @@callback_pointers[object_id] = boxed
        LibTF.linear_poti_set_position_callback_period ptr, value.total_milliseconds.to_u32
      end
    end

    # =======================================================================================
    # Data access
    # =======================================================================================

    # Returns the currently selected position on the poti in percents.
    # Positions are returned as integer values in the range `0..100`.
    def position
      if @regular_callback_interval.zero?
        LibTF.linear_poti_get_position ptr, out pos
        pos.to_i32
      else
        @position.to_i32
      end
    end
  end
end
