module TF

  # Simple wrapper class for any TinkerForge device or staple.
  # LibTF identifies entities through pointers to an opaque data structure.
  # Use `#ptr` to access this entity's pointer for direct calls to the Tinkerforge C API.
  class Entity
    def initialize
      @this_device = LibTF::Entity.new
    end

    # Returns a pointer used by LibTF to identify this entity.
    protected def ptr
      pointerof(@this_device)
    end
  end

end
