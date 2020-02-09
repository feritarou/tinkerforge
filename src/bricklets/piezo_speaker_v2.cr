module TF

  # A [Piezo Speaker 2.0 Bricklet](https://www.tinkerforge.com/doc/Hardware/Bricklets/PiezoSpeakerV2.html).
  #
  # ![Piezo Speaker 2.0 Bricklet](https://www.tinkerforge.com/en/doc/_images/Bricklets/bricklet_piezo_speaker_v2_tilted_800.jpg)
  class PiezoSpeakerV2Bricklet < Bricklet
    DEVICE_ID = 2145

    # =======================================================================================
    # Beeps
    # =======================================================================================

    # Stops the current beep if any is ongoing.
    def stop_beep
      LibTF.piezo_speaker_v2_set_beep ptr, 0, 0, LibTF::PIEZO_SPEAKER_V2_BEEP_DURATION_OFF
    end

    # Beeps with the given *frequency* and *volume*, optionally only for some *duration*.
    # The *volume* must be an integer between 0 (off) and 10 (very loud).
    # The *frequency* must be an integer between 50 Hertz and 15_000 Hertz.
    # If *duration* is left out, the beep will continue indefinitely until `#stop_beep` is called.
    def beep(frequency, volume = 5, duration : Time::Span? = nil)
      dur = if duration
              duration.total_milliseconds.to_u32
            else
              LibTF::PIEZO_SPEAKER_V2_BEEP_DURATION_INFINITE
            end
      LibTF.piezo_speaker_v2_set_beep ptr, frequency, volume, dur
    end

    # =======================================================================================
    # Alarms
    # =======================================================================================

    # Stops the current alarm if any is ongoing.
    def stop_alarm
      LibTF.piezo_speaker_v2_set_alarm ptr, 50, 100, 10, 10, 0, LibTF::PIEZO_SPEAKER_V2_ALARM_DURATION_OFF
    end

    # Sets an alarm that traverses a *frequency_range* with given *step_size*, *step_delay*, and *volume* – optionally only some *duration*.
    # If *duration* is left out, the alarm will continue indefinitely until `#stop_alarm` is called.
    def set_alarm(frequency_range : Range, step_size, step_delay, volume = 5, duration : Time::Span? = nil)
      dur = if duration
              duration.total_milliseconds.to_u32
            else
              LibTF::PIEZO_SPEAKER_V2_ALARM_DURATION_INFINITE
            end
      LibTF.piezo_speaker_v2_set_alarm ptr, frequency_range.begin, frequency_range.end, step_size, step_delay, volume, dur
    end

    # =======================================================================================
    # Update functions
    # =======================================================================================

    # Updates the volume of an ongoing beep or alarm.
    # The value must be an integer between 0 (off) and 10 (very loud).
    def volume=(value)
      LibTF.piezo_speaker_v2_update_volume ptr, value
  	end

  	# Updates the frequency of an ongoing beep.
    # The value must be an integer between 50 Hertz and 15_000 Hertz.
  	def frequency=(value)
      LibTF.piezo_speaker_v2_update_frequency ptr, value
    end

    # =======================================================================================
    # Status LED
    # =======================================================================================

    enum LEDMode : UInt8
      Off 			= 0
      On        = 1
      Heartbeat = 2
      Status    = 3
    end

    getter led_mode = LEDMode::Status
    def led_mode=(mode : LEDMode)
      @led_mode = mode
      LibTF.piezo_speaker_v2_set_status_led_config ptr, mode.value
    end

  end
end
