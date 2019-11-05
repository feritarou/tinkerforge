module TF

  # A Rotary Poti bricklet.
  class RotaryPotiBricklet < Device
    DEVICE_ID = 215

    # =======================================================================================
    # Constructor / destructor
    # =======================================================================================

    def initialize(@uid, @staple)
      super()
      LibTF.rotary_poti_create ptr, uid, staple.ptr
    end

    def finalize
      LibTF.rotary_poti_destroy ptr
    end

    # =======================================================================================
    # Data access
    # =======================================================================================

    def position
      LibTF.rotary_poti_get_position ptr, out pos
      pos
    end
  end
end
