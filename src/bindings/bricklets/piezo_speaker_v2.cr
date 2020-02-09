@[Link(
		ldflags: "#{__DIR__}/../../../obj/bricklet_piezo_speaker_v2.o"
	)]

lib LibTF
	alias PiezoSpeakerV2 = Entity

  # Creates the device object \c piezo_speaker_v2 with the unique device ID \c uid and adds
  # it to the IPConnection \c ipcon.
  fun piezo_speaker_v2_create(
    piezo_speaker_v2 : PiezoSpeakerV2*,
    uid : LibC::Char*,
    ipcon : IPConnection*
  ) : Void

  # Removes the device object \c piezo_speaker_v2 from its IPConnection and destroys it.
  # The device object cannot be used anymore afterwards.
  fun piezo_speaker_v2_destroy(
    piezo_speaker_v2 : PiezoSpeakerV2*
  ) : Void

	PIEZO_SPEAKER_V2_BEEP_DURATION_OFF = 0
	PIEZO_SPEAKER_V2_BEEP_DURATION_INFINITE = 4294967295

	# Beeps with the given frequency and volume for the duration.
	#
	# A duration of 0 stops the current beep if any is ongoing. A duration of 4294967295 results in an infinite beep.
	#
	# The following constants are available for this function:
	#
	# For duration:
	#
	# 		PIEZO_SPEAKER_V2_BEEP_DURATION_OFF = 0
	# 		PIEZO_SPEAKER_V2_BEEP_DURATION_INFINITE = 4294967295
	fun piezo_speaker_v2_set_beep(
		piezo_speaker_v2 : PiezoSpeakerV2*,
		frequency : UInt16,
		volume : UInt8,
		duration : UInt32
	) : LibC::Int

	# Returns the last beep settings as set by piezo_speaker_v2_set_beep(). If a beep is currently running it also returns the remaining duration of the beep.
	#
	# If the frequency or volume is updated during a beep (with piezo_speaker_v2_update_frequency() or piezo_speaker_v2_update_volume()) this function returns the updated value.
	#
	# The following constants are available for this function:
	#
	# For ret_duration:
	#
	# 		PIEZO_SPEAKER_V2_BEEP_DURATION_OFF = 0
	# 		PIEZO_SPEAKER_V2_BEEP_DURATION_INFINITE = 4294967295
	fun piezo_speaker_v2_get_beep(
		piezo_speaker_v2 : PiezoSpeakerV2*,
		ret_frequency : UInt16*,
		ret_volume : UInt8*,
		ret_duration : UInt32*,
		ret_duration_remaining : UInt32*
	) : LibC::Int

	PIEZO_SPEAKER_V2_ALARM_DURATION_OFF = 0
	PIEZO_SPEAKER_V2_ALARM_DURATION_INFINITE = 4294967295

	# Creates an alarm (a tone that goes back and force between two specified frequencies).
	#
	# The following parameters can be set:
	#
	# 		Start Frequency: Start frequency of the alarm.
	# 		End Frequency: End frequency of the alarm.
	# 		Step Size: Size of one step of the sweep between the start/end frequencies.
	# 		Step Delay: Delay between two steps (duration of time that one tone is used in a sweep).
	# 		Duration: Duration of the alarm.
	#
	# A duration of 0 stops the current alarm if any is ongoing. A duration of 4294967295 results in an infinite alarm.
	#
	# Below you can find two sets of example settings that you can try out. You can use these as a starting point to find an alarm signal that suits your application.
	#
	# Example 1: 10 seconds of loud annoying fast alarm
	#
	# 		Start Frequency = 800
	# 		End Frequency = 2000
	# 		Step Size = 10
	# 		Step Delay = 1
	# 		Volume = 10
	# 		Duration = 10000
	#
	# Example 2: 10 seconds of soft siren sound with slow build-up
	#
	# 		Start Frequency = 250
	# 		End Frequency = 750
	# 		Step Size = 1
	# 		Step Delay = 5
	# 		Volume = 0
	# 		Duration = 10000
	#
	# The following conditions must be met:
	#
	# 		Start Frequency: has to be smaller than end frequency
	# 		End Frequency: has to be bigger than start frequency
	# 		Step Size: has to be small enough to fit into the frequency range
	# 		Step Delay: has to be small enough to fit into the duration
	#
	# The following constants are available for this function:
	#
	# For duration:
	#
	# 		PIEZO_SPEAKER_V2_ALARM_DURATION_OFF = 0
	# 		PIEZO_SPEAKER_V2_ALARM_DURATION_INFINITE = 4294967295
	fun piezo_speaker_v2_set_alarm(
		piezo_speaker_v2 : PiezoSpeakerV2*,
		start_frequency : UInt16,
		end_frequency : UInt16,
		step_size : UInt16,
		step_delay : UInt16,
		volume : UInt8,
		duration : UInt32
	) : LibC::Int

	# Returns the last alarm settings as set by piezo_speaker_v2_set_alarm(). If an alarm is currently running it also returns the remaining duration of the alarm as well as the current frequency of the alarm.
	#
	# If the volume is updated during an alarm (with piezo_speaker_v2_update_volume()) this function returns the updated value.
	#
	# The following constants are available for this function:
	#
	# For ret_duration:
	#
	# PIEZO_SPEAKER_V2_ALARM_DURATION_OFF = 0
	# PIEZO_SPEAKER_V2_ALARM_DURATION_INFINITE = 4294967295
	#
	# For ret_duration_remaining:
	#
	# PIEZO_SPEAKER_V2_ALARM_DURATION_OFF = 0
	# PIEZO_SPEAKER_V2_ALARM_DURATION_INFINITE = 4294967295
	fun piezo_speaker_v2_get_alarm(
		piezo_speaker_v2 : PiezoSpeakerV2*,
		ret_start_frequency : UInt16*,
		ret_end_frequency : UInt16*,
		ret_step_size : UInt16*,
		ret_step_delay : UInt16*,
		ret_volume : UInt8*,
		ret_duration : UInt32*,
		ret_duration_remaining : UInt32*,
		ret_current_frequency : UInt16*
	) : LibC::Int

	# Updates the volume of an ongoing beep or alarm.
	fun piezo_speaker_v2_update_volume(
		piezo_speaker_v2 : PiezoSpeakerV2*,
		volume : UInt8
	) : LibC::Int

	# Updates the frequency of an ongoing beep.
	fun piezo_speaker_v2_update_frequency(
		piezo_speaker_v2 : PiezoSpeakerV2*,
		frequency : UInt16
	) : LibC::Int


  PIEZO_SPEAKER_V2_STATUS_LED_CONFIG_OFF 						= 0u8
  PIEZO_SPEAKER_V2_STATUS_LED_CONFIG_ON 						= 1u8
  PIEZO_SPEAKER_V2_STATUS_LED_CONFIG_SHOW_HEARTBEAT = 2u8
  PIEZO_SPEAKER_V2_STATUS_LED_CONFIG_SHOW_STATUS 		= 3u8

	fun piezo_speaker_v2_set_status_led_config(
		piezo_speaker_v2 : PiezoSpeakerV2*,
		config : UInt8
	) : LibC::Int
end
