module TF
  # A Master brick.
  class MasterBrick < Device
    DEVICE_ID = 13

    def initialize(@uid, @staple)
      super()
    end
  end
end
