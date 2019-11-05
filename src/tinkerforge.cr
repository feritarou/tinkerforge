require "./bindings/**"

module TF

  # Any TinkerForge device or staple.
  class Entity
    def initialize
      @this_device = LibTF::Object.new
    end

    # Returns a pointer used by LibTF to identify this specific object.
    protected def ptr
      pointerof(@this_device)
    end
  end

  # Abstract base class for any brick or bricklet.
  abstract class Device < Entity
    macro inherited
      getter uid : String, staple : Staple
    end

    # A string uniquely identifying this device.
    # The UID is also shown in TinkerForge's "brick viewer".
    abstract def uid : String

    # The staple which this device belongs to.
    abstract def staple : UInt64
  end
end

require "./**"
