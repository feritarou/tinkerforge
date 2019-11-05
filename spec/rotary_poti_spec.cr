require "./spec_helper"

describe "TF" do
  describe "::RotaryPotiBricklet" do
    it "should have the device id 215" do
      TF::RotaryPotiBricklet::DEVICE_ID.should eq 215
    end

    staple = TF::Staple.new

    it "there is a connected TF staple" do
      print "Please make sure that\n- a TF staple with master brick+wifi extension is within the current network, and\n- is configured in client mode,\nThen enter its IP address (leave blank for default): "
      ip_address = gets.not_nil!
      if ip_address.empty?
        ip_address = "192.168.1.15"
      end

      print "...and port (leave blank for default): "
      port_input = gets.not_nil!
      if port_input.empty?
        port = 4223
      else
        port = port_input.to_i
      end

      staple.connect \
        ip_address: ip_address,
        port: port,
        give_feedback: true

      staple.connected?
      .should be_true
    end

    it "should be found in the staple's devices list" do
      staple.devices.any? &.is_a? TF::RotaryPotiBricklet
      .should be_true
    end

    poti = staple.devices.select(TF::RotaryPotiBricklet).first.not_nil!

    it "should give -150 when turned to the left" do
      print "Please turn the connected rotary poti to the leftmost position and press enter!\n\e[s;"

      continue = Channel(Bool).new(1)
      continue.send true

      spawn do
        while continue.receive?
          value = poti.position
          scale_factor = 2
          normalized = value + 150
          bright = normalized / scale_factor
          dark = 300 / scale_factor - bright
          print "\e[u", "▓" * bright, "░" * dark, sprintf("%5d", value)
          sleep 10.milliseconds
          continue.send true
        end
      end

      gets
      continue.send false

      poti.position.should eq -150
    end

    it "should give +150 when turned to the right" do
      print "\nNow turn the connected rotary poti to the rightmost position and press enter!\n\e[s;"

      continue = Channel(Bool).new(1)
      continue.send true

      spawn do
        while continue.receive?
          value = poti.position
          scale_factor = 2
          normalized = value + 150
          bright = normalized / scale_factor
          dark = 300 / scale_factor - bright
          print "\e[u", "▓" * bright, "░" * dark, sprintf("%5d", value)
          sleep 10.milliseconds
          continue.send true
        end
      end

      gets
      continue.send false

      poti.position.should eq 150
    end
  end
end
