require "./spec_helper"

describe "TF" do
  describe "::Staple" do
    s = TF::Staple.new

    it "sets the established property to false on initialization" do
      s.connected?
      .should be_false
    end

    describe "#connect" do
      it "connects to a wifi-equipped TF staple in the current network" do
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

        print "Trying to connect to #{ip_address}, port #{port}"
        s.connect \
          ip_address: ip_address,
          port: port,
          give_feedback: true

        s.connected?
        .should be_true
      end
    end

    describe "#connected?" do
      it "returns true iff the staple is connected" do
        print "Please disconnect the staple from the network and press enter!"
        gets

        s.connected?
        .should be_false

        print "Now re-connect the staple, wait for 10 seconds and press enter again!"
        gets

        s.connected?
        .should be_true
      end
    end

    describe "#update_devices" do
      it "determines which bricks / bricklets are present in the staple" do
        s.update_devices
        sleep 100.milliseconds
        puts s.devices
        s.devices.size.should eq 3
      end
    end

    describe "#disconnect" do
      it "disconnects from the staple" do
        s.disconnect
        s.connected?
        .should be_false
      end
    end
  end
end
