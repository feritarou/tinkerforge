require "./entity"

module TF

  # Abstract base class for any brick or bricklet.
  abstract class Device < Entity

    # =======================================================================================
    # Virtual functions
    # =======================================================================================

    # This function is called internally by the enumeration callback to reconfigure all previous settings for the device after a connection is re-established or after a hardware reset.
    # Deriving classes need to carefully overwrite this function to ensure it transmits all settings (saved as, e.g., property values) to the brick/bricklet (again).
    abstract def configure

    # ---------------------------------------------------------------------------------------

    macro inherited
      macro inherited
        \{% type_prefix = @type.stringify.gsub(/Brick(let)?|TF::/, "").underscore.id %}

        # =======================================================================================
        # Properties
        # =======================================================================================

        # A string uniquely identifying this device.
        # The UID is also shown in TinkerForge's "brick viewer".
        getter uid : String

        # The staple which this device belongs to.
        getter staple : Staple

        # Returns `true` if this instance represents a *detached device*: e.g., a device that was once connected but isn't anymore. Use `#detach` to turn a device into a detached device, and `#attach` to restore all settings/properties after the device has been reconnected to a staple.
        getter? detached = false

        # The opposite of `#detached?`
        def attached?
          !detached?
        end

        def attached?(to staple)
          attached? && @staple == staple
        end

        # =======================================================================================
        # Constructor / destructor
        # =======================================================================================

        # Creates a device's software representation by referencing its unique device ID (uid) and the staple it is built into.
        def initialize(@uid, @staple)
          super()
          LibTF.\{{type_prefix}}_create ptr, uid, staple.ptr
        end

        # Destroys a device's software representation.
        def finalize
          LibTF.\{{type_prefix}}_destroy ptr
        end

        # =======================================================================================
        # Detach from / attach to staple
        # =======================================================================================

        def detach
          if attached?
            LibTF.\{{type_prefix}}_destroy ptr
            @detached = true
          end
        end

        def attach(to new_staple = @staple)
          if detached?
            LibTF.\{{type_prefix}}_create ptr, @uid, new_staple.ptr
            @staple = new_staple
            @detached = false
            configure
          end
        end

      end
    end
  end

  # A TinkerForge [brick](https://www.tinkerforge.com/doc/Primer.html#primer-bricks).
  abstract class Brick < Device
  end

  # A TinkerForge [bricklet](https://www.tinkerforge.com/doc/Primer.html#primer-bricklets).
  abstract class Bricklet < Device
  end

end
