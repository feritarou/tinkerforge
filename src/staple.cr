require "socket"
require "./tinkerforge"

module TF

  # A staple of TinkerForge bricks and bricklets.
  #
  # ![A staple of TinkerForge bricks](https://www.tinkerforge.com/de/doc/_images/brick_master_stack_front_big_350.jpg)
  #
  # The staple can be connected to the client in two ways:
  # - through a USB cable - this requires `brickd` ("brick daemon") to be running on the client computer,
  # - wirelessly, if the staple comes with a master brick and wifi extension.
  #
  # Once connected, accessing a brick or bricklet is as simple as it gets:
  #      staple = TF::Staple.new
  #      staple.connect IP, HOST
  #      if staple.connected?
  #        puts staple.rotary_poti.position
  #      end
  class Staple < Entity

    {% begin %}
    {% supported = [:RotaryPotiBricklet, :SilentStepperBrick, :MasterBrick] %}

    # =======================================================================================
    # Class variables
    # =======================================================================================

    # A class-level counter incremented whenever an instance is created, to provide each of them with a unique `id`.
    @@available_id = 0u64

    # A class-level hash keeping all information provided by `device_callback`.
    @@devices = {} of UInt64 => Array(Device)

    # A class-level hash keeping all Staple instances.
    @@instances = {} of UInt64 => Staple

    # =======================================================================================
    # Instance variables
    # =======================================================================================

    # A number uniquely identifying this staple.
    #
    # This is needed to distribute the information on bricks and bricklets, arriving as a class-level enumeration callback, correctly among all connected staples.
    @id : UInt64

    #

    # =======================================================================================
    # Constructor / destructor
    # =======================================================================================

    def initialize
      super

      @id = @@available_id
      @@available_id += 1
      @connection_established = false

      @@devices[@id] = [] of Device
      @@instances[@id] = self

      LibTF.ipcon_create ptr
      LibTF.ipcon_register_callback \
        ptr,
        LibTF::IPCON_CALLBACK_ENUMERATE,
        ->Staple.device_callback(LibC::Char*, LibC::Char*, LibC::Char, UInt8*, UInt8*, UInt16, UInt8, Void*).pointer,
        Pointer(Void).new(@id)
    end

    # ---------------------------------------------------------------------------------------

    # Destroys the object internally maintained by the TinkerForge API.
    def finalize
      disconnect if @connection_established
      LibTF.ipcon_destroy ptr
    end

    # =======================================================================================
    # Open / close connection
    # =======================================================================================

    # A failure to establish a connection to the staple.
    class ConnectionException < Exception
    end

    # Connects to a staple of TinkerForge bricks identified by its *ip_address* and *port*.
    #
    # The default values are suitable for a connection through a USB cable.
    #
    # If attempts to establish a connection fail for longer than *timeout*, the function raises a `ConnectionException` or `Errno`.
    def connect(@ip_address = "localhost", @port = 4223, timeout = 3.seconds, give_feedback feedback_required = true, feedback_io = STDOUT)
      return if @connection_established

      print_dots = Channel(Bool).new(1)

      if feedback_required
        print_dots.send true

        spawn do
          while print_dots.receive?
            feedback_io.print "."
            sleep 0.5.seconds
            print_dots.send true
          end
        end
      end

      begin
        test_connection = TCPSocket.new ip_address, port, connect_timeout: timeout.seconds

        if test_connection.nil? || test_connection.closed?
          raise ConnectionException.new
        else
          test_connection.close
          LibTF.ipcon_connect ptr, ip_address, port
          @connection_established = true

          if feedback_required
            print_dots.send false
            feedback_io.puts "connection established!"
          end
        end
      rescue
        feedback_io.puts "connection failed!" if feedback_required
      end
    end

    # ---------------------------------------------------------------------------------------

    # Disconnects from the TinkerForge staple.
    def disconnect
      if @connection_established
        LibTF.ipcon_disconnect ptr
        @connection_established = false
      end
    end

    # ---------------------------------------------------------------------------------------

    # Returns `true` if the connection has been successfully established, otherwise `false`.
    #
    # As there is no other reliable method to determine if a staple is actually connected, this function calls `#update_devices` and checks for the presence of at least one brick.
    # This also means that if you test your connection using `#connected?` before accessing a device, you should not call `#update_devices` again - instead, just move on and access them like this:
    # ```
    # if staple.connected?
    #   if staple.devices.any? &.is_a? SilentStepperBrick
    #     # move it
    #   end
    # end
    def connected?
      return false unless @connection_established

      state = LibTF.ipcon_get_connection_state ptr

      if state == LibTF::IPCON_CONNECTION_STATE_CONNECTED
        update_devices
        sleep 100.milliseconds

        if devices.empty?
          return false
        else
          return true
        end
      else
        return false
      end
    end

    # =======================================================================================
    # Brick / bricklet lookup
    # =======================================================================================

    # :nodoc:
    def self.device_callback(uid : LibC::Char*, conn_uid : LibC::Char*, pos : LibC::Char, hw : UInt8*, fw : UInt8*, device_identifier : UInt16, en : UInt8, data : Void*)

      staple_id = data.address

      device = case device_identifier
      {% for type in supported %}
      when {{type.id}}::DEVICE_ID
        {{type.id}}.new String.new(uid), @@instances[staple_id]
      {% end %}
      end

      if device
        @@devices[staple_id] << device
      end
    end

    # ---------------------------------------------------------------------------------------

    # Searches the staple for bricks and bricklets, then updates the list of `#devices` accordingly.
    #
    # As the staple is examined by means of callback functions, it may take some time until the list is completed.
    def update_devices
      @@devices[@id].clear
      LibTF.ipcon_enumerate ptr
    end

    # =======================================================================================
    # Brick / bricklet access
    # =======================================================================================

    # Returns an array of all `Device`s (bricks/bricklets) in the staple.
    def devices
      @@devices[@id]
    end

    {% for type in supported %}

    # Returns the `{{type.id}}` in the staple.
    #
    # This function assumes there is only one device of this kind in the staple; if there are multiple, it will just return the first one found.
    def {{type.id.stringify.gsub(/Brick(let)?/, "").underscore.id}}
      (devices.select &.is_a? {{type.id}}).first.as({{type.id}})
    end
    {% end %}
    {% end %}
  end
end
