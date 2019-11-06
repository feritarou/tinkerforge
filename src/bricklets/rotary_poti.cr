module TF

  # A Rotary Poti bricklet.
  class RotaryPotiBricklet < Device
    DEVICE_ID = 215

    # =======================================================================================
    # Data access
    # =======================================================================================

    def position
      LibTF.rotary_poti_get_position ptr, out pos
      pos
    end
  end
end
