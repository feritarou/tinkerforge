require "./bindings/**"

module TF

  # Any TinkerForge device or staple.
  class Entity
    def initialize
      @this_device = LibTF::Entity.new
    end

    # Returns a pointer used by LibTF to identify this specific object.
    protected def ptr
      pointerof(@this_device)
    end
  end

  # Abstract base class for any brick or bricklet.
  abstract class Device < Entity
    macro inherited
      {% type_prefix = @type.stringify.gsub(/Brick(let)?|TF::/, "").underscore.id %}
      # A string uniquely identifying this device.
      # The UID is also shown in TinkerForge's "brick viewer".
      getter uid : String

      # The staple which this device belongs to.
      getter staple : Staple

      def initialize(@uid, @staple)
        super()
        LibTF.{{type_prefix}}_create ptr, uid, staple.ptr
      end

      def finalize
        LibTF.{{type_prefix}}_destroy ptr
      end
    end
  end
end

require "./**"
