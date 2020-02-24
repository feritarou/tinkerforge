@[Link(
		ldflags: "#{__DIR__}/../../obj/ip_connection.o"
	)]

lib LibTF
	alias IPConnection = Entity

  # Creates an IP Connection object that can be used to enumerate the available
  # devices. It is also required for the constructor of Bricks and Bricklets.
  fun ipcon_create(
    ipcon : IPConnection*
  ) : Void

  # Destroys the IP Connection object. Calls ipcon_disconnect internally.
  # The connection to the Brick Daemon gets closed and the threads of the
  # IP Connection are terminated.
  fun ipcon_destroy(
    ipcon : IPConnection*
  ) : Void

  # Creates a TCP/IP connection to the given host and port. The host and
  # port can point to a Brick Daemon or to a WIFI/Ethernet Extension.

  # Devices can only be controlled when the connection was established
  # successfully.

  # Blocks until the connection is established and returns an error code if
  # there is no Brick Daemon or WIFI/Ethernet Extension listening at the given
  # host and port.
  fun ipcon_connect(
    ipcon : IPConnection*,
    host : LibC::Char*,
    port : UInt16
  ) : LibC::Int

  # Disconnects the TCP/IP connection from the Brick Daemon or the WIFI/Ethernet
  # Extension.
  fun ipcon_disconnect(
    ipcon : IPConnection*
  ) : LibC::Int

  # Performs an authentication handshake with the connected Brick Daemon or
  # WIFI/Ethernet Extension. If the handshake succeeds the connection switches
  # from non-authenticated to authenticated state and communication can
  # continue as normal. If the handshake fails then the connection gets closed.
  # Authentication can fail if the wrong secret was used or if authentication
  # is not enabled at all on the Brick Daemon or the WIFI/Ethernet Extension.
  #
  # For more information about authentication see
  # http://www.tinkerforge.com/en/doc/Tutorials/Tutorial_Authentication/Tutorial.html
  fun ipcon_authenticate(
    ipcon : IPConnection*,
    secret : LibC::Char[64]
  ) : LibC::Int

  # Can return the following states:
  #
  # - IPCON_CONNECTION_STATE_DISCONNECTED: No connection is established.
  # - IPCON_CONNECTION_STATE_CONNECTED: A connection to the Brick Daemon or
  #   the WIFI/Ethernet Extension is established.
  # - IPCON_CONNECTION_STATE_PENDING: IP Connection is currently trying to
  #   connect.
  fun ipcon_get_connection_state(
    ipcon : IPConnection*
  ) : LibC::Int

	IPCON_CONNECTION_STATE_DISCONNECTED = 0
	IPCON_CONNECTION_STATE_CONNECTED 		= 1
	IPCON_CONNECTION_STATE_PENDING 			= 2 # auto-reconnect in progress

  # Enables or disables auto-reconnect. If auto-reconnect is enabled,
  # the IP Connection will try to reconnect to the previously given
  # host and port, if the connection is lost.
  #
  # Default value is *true*.
  fun ipcon_set_auto_reconnect(
    ipcon : IPConnection*,
    auto_reconnect : LibC::Int
  ) : Void

  # Returns *true* if auto-reconnect is enabled, *false* otherwise.
  fun ipcon_get_auto_reconnect(
    ipcon : IPConnection*
  ) : LibC::Int

  # Sets the timeout in milliseconds for getters and for setters for which the
  # response expected flag is activated.
  # Default timeout is 2500.
  fun ipcon_set_timeout(
    ipcon : IPConnection*,
    timeout : UInt32
  ) : Void

  # Returns the timeout as set by ipcon_set_timeout.
  fun ipcon_get_timeout(
    ipcon : IPConnection*
  ) : UInt32

  # Broadcasts an enumerate request. All devices will respond with an enumerate
  # callback.
  fun ipcon_enumerate(
    ipcon : IPConnection*
  ) : LibC::Int

  # Stops the current thread until ipcon_unwait is called.
  #
  # This is useful if you rely solely on callbacks for events, if you want
  # to wait for a specific callback or if the IP Connection was created in
  # a thread.
  #
  # ipcon_wait and ipcon_unwait act in the same way as "acquire" and "release"
  # of a semaphore.
  fun ipcon_wait(
    ipcon : IPConnection*
  ) : Void

  # Unwaits the thread previously stopped by ipcon_wait.
  #
  # ipcon_wait and ipcon_unwait act in the same way as "acquire" and "release"
  # of a semaphore.
  fun ipcon_unwait(
    ipcon : IPConnection*
  ) : Void

  # Registers a callback for a given ID.
  fun ipcon_register_callback(
    ipcon : IPConnection*,
    id : Int16,
    callback : Void*,
    user_data : Void*
  ) : Void

	IPCON_CALLBACK_CONNECTED 		= 0
	IPCON_CALLBACK_DISCONNECTED = 1
	IPCON_CALLBACK_ENUMERATE 		= 253

	IPCON_ENUMERATION_TYPE_AVAILABLE 		= 0
	IPCON_ENUMERATION_TYPE_CONNECTED 		= 1
	IPCON_ENUMERATION_TYPE_DISCONNECTED = 2

  E_OK = 0
  E_TIMEOUT = -1
  E_NO_STREAM_SOCKET = -2
  E_HOSTNAME_INVALID = -3
  E_NO_CONNECT = -4
  E_NO_THREAD = -5
  E_NOT_ADDED = -6 # not used anymore
  E_ALREADY_CONNECTED = -7
  E_NOT_CONNECTED = -8
  E_INVALID_PARAMETER = -9
  E_NOT_SUPPORTED = -10
  E_UNKNOWN_ERROR_CODE = -11
  E_STREAM_OUT_OF_SYNC = -12
  E_INVALID_UID = -13
  E_NON_ASCII_CHAR_IN_SECRET = -14
  E_WRONG_DEVICE_TYPE = -15
end
