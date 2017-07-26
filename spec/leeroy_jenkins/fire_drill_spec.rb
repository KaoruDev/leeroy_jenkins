require "timeout"
require_relative "../spec_helper"

require "lib/leeroy_jenkins/fire_drill"
require "lib/leeroy_jenkins/logger"

module LeeroyJenkins
  RSpec.describe FireDrill do
    describe "#start" do
      before(:each) do
        allow_any_instance_of(FireDrill).to receive(:pause)
      end

      it "will loop until the disruption count is at it's limit" do
        fire_drill = FireDrill.new(disruption_limit: 1)

        expect(fire_drill).to receive(:victim)
          .and_return(Victim.new(target: "example.com"))

        allow_any_instance_of(Disruption::Network).to receive(:probability)
          .and_return(0.9)

        fire_drill.start

        [
          "sudo iptables-save > ~/default_iptables.rules",
          "echo 'cat ~/default_iptables.rules | sudo iptables-restore' " \
            "| at now + 60 minutes",
          "echo 'rm ~/default_iptables.rules' | at now + 61 minutes",
          "sudo iptables -A INPUT -p 22 -j ACCEPT",
          "sudo iptables -A OUTPUT --sport 22 -j ACCEPT",
          "sudo iptables -A OUTPUT " \
            "-m statistic --mode random --probability 0.9 " \
            "-j DROP",
          "sudo iptables -A INPUT " \
            "-m statistic --mode random --probability 0.9 " \
            "-j DROP"
        ].each do |rule|
          expect(Logger.test_log).to include(rule)
        end
      end

      it "will loop until time has expired" do
        fire_drill = FireDrill.new(duration: 1)

        allow(fire_drill).to receive(:time_to_disrupt)
          .and_return(false)
        expect(fire_drill).to receive(:now).and_return(0)
        expect(fire_drill).to receive(:now).and_return(100)
        expect(fire_drill).to receive(:now).and_return(200)
        expect(fire_drill).to receive(:now).and_return(3000)
        expect(fire_drill).to receive(:now).and_return(7200) # 2 hours

        Timeout.timeout(0.5) {
          fire_drill.start
        }
      end
    end
  end
end
