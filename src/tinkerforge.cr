require "./bindings.cr"
require "socket"

module TF

  # A wrapper class capturing a TinkerForge device or staple.
  class Device
    def initialize
      @this_device = LibTF::Device.new
    end

    # Returns a pointer used by LibTF to identify this specific object.
    protected def ptr
      pointerof(@this_device)
    end
  end

  # ---------------------------------------------------------------------------------------

  # Represents a staple of TinkerForge bricks and bricklets.
  #
  # The staple can be connected to the client either through a USB cable or wirelessly,
  # if the staple to connect to contains a master brick with a wifi extension.
  class Staple < Device

    # =======================================================================================
    # Constructor / destructor
    # =======================================================================================

    def initialize
      super
      LibTF.ipcon_create ptr
      @connection_established = false
    end

    # ---------------------------------------------------------------------------------------

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
    # The staple can be connected to the client computer either through a USB cable,
    # in which case *ip_address* should be "localhost",
    # or wirelessly (provided the staple contains a master brick with wifi extension).
    #
    # If attempts to establish a connection fail for longer than *timeout*, the function raises.
    def connect(ip_address = "localhost", port = 4223, timeout = 3.seconds, give_feedback feedback_required = true, feedback_io = STDOUT)
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
    def established?
      @connection_established
    end
  end
end
