require "./spec_helper"

describe "TF" do
  describe "::SilentStepperBrick" do
    it "should have the device id 19" do
      TF::SilentStepperBrick::DEVICE_ID.should eq 19
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
      staple.devices.any? &.is_a? TF::SilentStepperBrick
      .should be_true
    end

    stepper = staple.devices.select(TF::SilentStepperBrick).first.not_nil!
    stepper.enable
    stepper.max_velocity = 1000

    stepper.drive

    if staple.devices.any? &.is_a? TF::RotaryPotiBricklet
      poti = staple.devices.select(TF::RotaryPotiBricklet).first.not_nil!
      print "Move to poti to vary the stepper's velocity - press enter to stop!\n\e[s;"

      continue = Channel(Bool).new(1)
      continue.send true

      spawn do
        while continue.receive?
          value = poti.position + 150
          stepper.max_velocity = value * 20
          sleep 5.milliseconds
          continue.send true
        end
      end

      gets
      continue.send false
    else
      print "Press Q / A to increase / reduce the stepper's velocity!"
      while (v = stepper.max_velocity) > 0
        c = STDIN.read_char
        case c
        when 'Q', 'q' then stepper.max_velocity += 100
        when 'A', 'a' then stepper.max_velocity -= 100
        end
      end
    end

    stepper.stop
  end
end
