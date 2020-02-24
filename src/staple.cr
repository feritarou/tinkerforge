require "socket"
require "./tinkerforge"

module TF

  # A staple of TinkerForge bricks and bricklets.
  #
  # ![A staple of TinkerForge bricks](https://www.tinkerforge.com/de/doc/_images/brick_master_stack_front_big_350.jpg)
  #
  # The staple can be connected to the client in two ways:
  # - through a USB cable: requires `brickd` ("brick daemon") to be running on the client computer,
  # - wirelessly: if the staple comes with a master brick and wifi extension.
  #
  # Once connected, accessing a brick or bricklet becomes as simple as it gets:
  #      staple = TF::Staple.new
  #      staple.connect IP, HOST
  #      if staple.connected?
  #        puts staple.rotary_poti.position
  #      end
  class Staple < Entity

    # =======================================================================================
    # Enums
    # =======================================================================================

    enum ConnectionState
      Connected    = LibTF::IPCON_CONNECTION_STATE_CONNECTED
      Disconnected = LibTF::IPCON_CONNECTION_STATE_DISCONNECTED
      Pending      = LibTF::IPCON_CONNECTION_STATE_PENDING
    end

    # =======================================================================================
    # Properties
    # =======================================================================================

    # Returns the current state of the connection.
    def connection_state
      ConnectionState.new LibTF.ipcon_get_connection_state ptr
    end

    delegate connected?, disconnected?, to: connection_state

    # ---------------------------------------------------------------------------------------

    # The IP address this staple is connected at.
    # An empty value signifies no connection.
    getter ip_address = ""

    # The port this staple is connected at.
    getter port = 4223

    # ---------------------------------------------------------------------------------------

    # Returns an array of all `Device`s (bricks/bricklets) in the staple.
    def devices
      @@devices.values.select &.attached? to: self
    end

    # ---------------------------------------------------------------------------------------

    # Accesses a brick or bricklet in this staple by its UID.
    # The device is returned as a generic `Device` instance, so you need to restrict it to the appropriate brick/bricklet type for further use.
    # If no device with the UID is found, this function raises an `IndexError`.
    def [](uid) : Device
      self[uid]? || raise IndexError.new "No device with UID #{uid} found in the staple."
    end

    # Looks up a brick or bricklet in this staple by its UID and returns it if found.
    # The device is returned as a generic `Device` instance, so you need to restrict it to the appropriate brick/bricklet type for further use.
    # If no device with the UID is found, this function returns `nil`.
    def []?(uid) : Device?
      if (d = @@devices[uid]?) && d.attached? to: self
        d
      else
        nil
      end
    end

    # ---------------------------------------------------------------------------------------

    {% begin %}
    {% supported = [:MasterBrick, :SilentStepperBrick, :RotaryPotiBricklet, \
                    :LinearPotiBricklet, :LineBricklet, :PiezoSpeakerV2Bricklet ] %}

    {% for type in supported %}
    # Returns a `{{type.id}}` in the staple, or `nil` if no such device is found.
    #
    # This function assumes there is at most one device of this kind in the staple; if there are multiple, it is undefined which one is returned.
    def {{type.id.stringify.gsub(/Brick(let)?$/, "").underscore.id}}
      if (of_that_type = devices.select &.is_a? {{type.id}}) && of_that_type.size > 0
        of_that_type.first.as {{type.id}}
      else
        nil
      end
    end
    {% end %}

    # =======================================================================================
    # Class variables
    # =======================================================================================

    # A class-level hash storing all information provided by `cb_enumerate`.
    @@devices = {} of String => Device

    # =======================================================================================
    # Instance variables
    # =======================================================================================

    # =======================================================================================
    # Constructor / destructor
    # =======================================================================================

    def initialize
      super

      LibTF.ipcon_create ptr

      # Register callbacks and transmit this instance's id as the "address" the void* user_data pointer points to
      LibTF.ipcon_register_callback \
        ptr,
        LibTF::IPCON_CALLBACK_ENUMERATE,
        ->Staple.cb_enumerate(LibC::Char*, LibC::Char*, LibC::Char, UInt8*, UInt8*, UInt16, UInt8, Void*).pointer,
        Box.box(self)

      LibTF.ipcon_register_callback \
        ptr,
        LibTF::IPCON_CALLBACK_CONNECTED,
        ->Staple.cb_connected(UInt8, Void*).pointer,
        Box.box(self)

      LibTF.ipcon_register_callback \
        ptr,
        LibTF::IPCON_CALLBACK_DISCONNECTED,
        ->Staple.cb_disconnected(UInt8, Void*).pointer,
        Box.box(self)
    end

    # ---------------------------------------------------------------------------------------

    # Destroys the object internally maintained by the TinkerForge API.
    def finalize
      LibTF.ipcon_destroy ptr
      # ipcon_destroy will close any open connections automatically.
    end

    # =======================================================================================
    # Methods
    # =======================================================================================

    # Returns `true` if a connection is established and responds to a ping, otherwise `false`.
    # Note that `false` is also returned for pending connection attempts that have yet neither failed nor succeeded.
    def responding?
      connected? && alive?
    end

    # ---------------------------------------------------------------------------------------

    # Pings the specified address to find out if it is alive.
    def alive?(ip_address = @ip_address, port = @port)
      system("ping -c1 -i0.2 -w1 #{ip_address} >/dev/null")
    end

    # ---------------------------------------------------------------------------------------

    # Connects to a staple of TinkerForge bricks through an IP connection (*ip_address* and *port*).
    #
    # The default values are suitable for a connection through a USB cable, assuming `brickd` is running. If attempts to establish a connection fail for longer than *timeout*, the function raises a `ConnectionException` or `Errno`.
    def connect(ip_address = "localhost", port = 4223, timeout = 3.seconds, give_feedback  feedback_required = true, feedback_io = STDOUT)
      if connected?
        feedback_io.puts "Staple is already connected" if feedback_required
        return
      end

      @ip_address, @port = ip_address, port

      start = Time.monotonic
      while Time.monotonic - start < timeout
        if connected?
          feedback_io.puts "connection established!" if feedback_required
          return
        else
          feedback_io.print "." if feedback_required
          LibTF.ipcon_connect(ptr, @ip_address, @port) if alive?
        end
        sleep 100.milliseconds
      end

      feedback_io.puts "connection timeout!" if feedback_required
    end

    # ---------------------------------------------------------------------------------------

    # Disconnects from the TinkerForge staple.
    def disconnect
      if connected?
        devices.each &.detach
        LibTF.ipcon_disconnect ptr
      end
    end

    # ---------------------------------------------------------------------------------------

    # Searches the staple for bricks and bricklets, then updates the list of `#devices` accordingly.
    # As the staple is examined by means of callback functions, it may take some time until the list is completed.
    def update_devices
      devices.each &.detach
      LibTF.ipcon_enumerate ptr
    end

    # =======================================================================================
    # Callbacks
    # =======================================================================================

    # :nodoc:
    def self.cb_enumerate(uid : LibC::Char*, conn_uid : LibC::Char*, pos : LibC::Char, hw : UInt8*, fw : UInt8*, device_identifier : UInt16, en : UInt8, data : Void*)
      staple = Box(Staple).unbox data

      case en
      when LibTF::IPCON_ENUMERATION_TYPE_DISCONNECTED
        staple.devices.each &.detach

      when LibTF::IPCON_ENUMERATION_TYPE_CONNECTED,
           LibTF::IPCON_ENUMERATION_TYPE_AVAILABLE
        uid_str = String.new(uid)
        if @@devices.has_key? uid_str
          dev = @@devices[uid_str]
          dev.attach to: staple
          dev.configure
        else
          dev = \
            case device_identifier
            {% for type in supported %}
            when {{type.id}}::DEVICE_ID
              {{type.id}}.new uid_str, staple
            {% end %}
            end

          if dev.nil?
            raise "Unsupported tinkerforge component (device ID #{device_identifier}) found in staple!"
          else
            @@devices[uid_str] = dev
          end
        end
      end
    end

    # ---------------------------------------------------------------------------------------

    # :nodoc:
    def self.cb_connected(reason : UInt8, data : Void*)
      staple = Box(Staple).unbox data
      LibTF.ipcon_enumerate staple.ptr
    end

    # ---------------------------------------------------------------------------------------

    # :nodoc:
    def self.cb_disconnected(reason : UInt8, data : Void*)
      staple = Box(Staple).unbox data
      staple.devices.each &.detach
    end

    {% end %}

  end
end
