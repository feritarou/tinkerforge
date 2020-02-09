enum Is : UInt8
  Ignored    = 120
  Within     = 105
  Without    = 111
  LowerThan  = 60
  HigherThan = 62
end

module TF

  # A [Line Bricklet](https://www.tinkerforge.com/doc/Hardware/Bricklets/Line.html).
  #
  # ![Line Bricklet](https://www.tinkerforge.com/en/doc/_images/Bricklets/bricklet_line_tilted_800.jpg)
  class LineBricklet < Bricklet
    include RegularCallback

    DEVICE_ID = 241

    # =======================================================================================
    # Class variables
    # =======================================================================================

    @@reached_callback_pointers = {} of UInt64 => Void*

    # =======================================================================================
    # Instance variables
    # =======================================================================================

    @reflectivity = 0u16

    # =======================================================================================
    # Callbacks
    # =======================================================================================

    # :nodoc:
    def cb_reflectivity(reflectivity)
      @reflectivity = reflectivity
    end

    # =======================================================================================
    # Data access mode
    # =======================================================================================

    getter regular_callback_interval = Time::Span.zero

    def regular_callback_interval=(value : Time::Span)
      @regular_callback_interval = value

      if value.zero?
        @@callback_pointers.delete object_id
        LibTF.line_set_reflectivity_callback_period ptr, 0u32
      else
        boxed = Box.box(->cb_reflectivity(UInt16))

        LibTF.line_register_callback(
          ptr, LibTF::LINE_CALLBACK_REFLECTIVITY,
          Proc(UInt16, Void*, Void).new do |reflectivity, user_data|
            unboxed = Box(Proc(UInt16, Void)).unbox(user_data)
            unboxed.call(reflectivity)
          end.pointer,
          boxed \
        )

        @@callback_pointers[object_id] = boxed
        LibTF.line_set_reflectivity_callback_period ptr, value.total_milliseconds.to_u32
      end
    end

    # =======================================================================================
    # Data access
    # =======================================================================================

    # Returns the currently measured reflectivity. The reflectivity is a value between 0 (not reflective) and 4095 (very reflective).
    #
    # Usually black has a low reflectivity while white has a high reflectivity.
    def reflectivity
      if @regular_callback_interval.zero?
        LibTF.line_get_reflectivity ptr, out refl
        refl
      else
        @reflectivity
      end
    end

    # =======================================================================================
    # Register an event callback
    # =======================================================================================

    def when_reflectivity(is : Is, reference : Int | Range, debounce = 100, &block : UInt16 ->)
      if is.ignored?
        @@reached_callback_pointers.delete object_id
        LibTF.line_set_reflectivity_callback_threshold ptr, is.value, 0, 0
      else
        boxed = Box.box(block)
        LibTF.line_register_callback(
          ptr, LibTF::LINE_CALLBACK_REFLECTIVITY_REACHED,
          Proc(UInt16, Void*, Void).new do |reflectivity, user_data|
            unboxed = Box(Proc(UInt16, Void)).unbox(user_data)
            unboxed.call(reflectivity)
          end.pointer,
          boxed \
        )

        @@reached_callback_pointers[object_id] = boxed
        min, max = case reference
                   when Range then {reference.begin, reference.end}
                   else            {reference, 0}
                   end

        LibTF.line_set_reflectivity_callback_threshold ptr, is.value, min, max
        LibTF.line_set_debounce_period ptr, debounce
      end
    end
  end
end
