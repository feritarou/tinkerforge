require "./spec_helper"

# =======================================================================================
# Test suite for the TF module
# =======================================================================================

describe "TF" do
  describe "::IPConnection" do
    c = TF::IPConnection.new

    it "sets the established property to false on initialization" do
      c.established?
      .should be_false
    end

    describe "#connect" do
      it "connects to a wifi-equipped TF staple in the current network" do
        print "Please make sure that\n- a TF staple with master brick+wifi extension is within the current network, and\n- is configured in client mode,\nThen enter its IP address: "
        ip_address = gets.not_nil!

        print "...and port: "
        port = gets.not_nil!.to_i

        print "Trying to connect to #{ip_address}, port #{port}"
        c.connect \
          ip_address: ip_address,
          port: port,
          give_feedback: true

        c.established?
        .should be_true
      end
    end

    describe "#disconnect" do
      it "disconnects from the staple" do
        c.disconnect
        c.established?
        .should be_false
      end
    end
  end
end
