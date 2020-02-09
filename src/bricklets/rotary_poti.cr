module TF

  # A [Rotary Poti Bricklet](https://www.tinkerforge.com/doc/Hardware/Bricklets/Rotary_Poti.html).
  #
  # ![Rotary Poti Bricklet](https://www.tinkerforge.com/doc/_images/Bricklets/bricklet_rotary_poti_tilted_800.jpg)
  class RotaryPotiBricklet < Bricklet
    DEVICE_ID = 215

    # =======================================================================================
    # Data access
    # =======================================================================================

    # Returns the currently selected position on the poti in degrees.
    # Positions are returned as integer values in the range `-150..150`.
    def position
      LibTF.rotary_poti_get_position ptr, out pos
      pos
    end
  end
end
