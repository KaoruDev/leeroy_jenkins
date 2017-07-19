require_relative "../../spec_helper"
require "spec/factories/ssh_session"

require "lib/leeroy_jenkins/disruption/network"

module LeeroyJenkins
  class Disruption
    RSpec.describe Network do
      let(:ssh_session) { Factories::SshSession.new }
      let(:network_configs) {
        { ssh: ssh_session, probability: probability }
      }
      let(:dependency_url) { "api.example.org" }
      let(:dependency_url_2) { "api2.example.org" }
      let(:dependencies) { [dependency_url, dependency_url_2] }
      let(:chosen) { "web.example.org" }
      let(:probability) { 0.76 }

      let(:victim) {
        Victim.new(chosen: chosen, dependencies: dependencies)
      }

      describe ".probability" do
        it "will return whatever it is set to" do
          network = Network.new(victim, probability: 0.1)
          expect(network.send(:probability)).to eq(0.1)
          expect(network.send(:probability)).to eq(0.1)
          expect(network.send(:probability)).to eq(0.1)
          expect(network.send(:probability)).to eq(0.1)
        end

        it "will return a float between a range" do
          network = Network.new(victim)
          expect(network.send(:probability)).to be_within(0.75).of(0.95)
          expect(network.send(:probability)).to be_within(0.75).of(0.95)
          expect(network.send(:probability)).to be_within(0.75).of(0.95)
          expect(network.send(:probability)).to be_within(0.75).of(0.95)
        end
      end

      describe ".run!" do
        before do
          expect(ssh_session).to receive(:exec!)
            .with("echo 'sudo service iptables restart' " \
                  "| at now + 60 minutes")
            .ordered
            .once

          # accepts all ssh connections
          expect(ssh_session).to receive(:exec!)
            .with("sudo iptables -A INPUT -p 22 -J ACCEPT")
            .ordered
            .once

          expect(ssh_session).to receive(:exec!)
            .with("sudo iptables -A OUTPUT --sport 22 -J ACCEPT")
            .ordered
            .once
        end

        context "with a victim with no targets" do
          let(:victim) { Victim.new(chosen: chosen) }

          it "will drop a percentage of all outgoing / incoming packets" do
            expect(ssh_session).to receive(:exec!)
              .with("sudo iptables -A OUTPUT " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-J DROP")
              .ordered
              .once

            expect(ssh_session).to receive(:exec!)
              .with("sudo iptables -A INPUT " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-J DROP")
              .ordered
              .once

            network = Network.new(victim, network_configs)
            network.run!

            expect(ssh_session.host).to eq(victim.chosen)
          end
        end

        context "with a victim with 2 dependencies" do
          it "will drop a percentage of out going and incoming " \
             "packets to clients " do
            expect(ssh_session).to receive(:exec!)
              .with("sudo iptables -A OUTPUT " \
                    "--destination #{dependency_url} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-J DROP")
              .ordered
              .once

            expect(ssh_session).to receive(:exec!)
              .with("sudo iptables -A OUTPUT " \
                    "--destination #{dependency_url_2} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-J DROP")
              .ordered
              .once

            # drops packets outgoing to client
            expect(ssh_session).to receive(:exec!)
              .with("sudo iptables -A INPUT " \
                    "--source #{dependency_url} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-J DROP")
              .ordered

            expect(ssh_session).to receive(:exec!)
              .with("sudo iptables -A INPUT " \
                    "--source #{dependency_url_2} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-J DROP")
              .ordered
              .once

            network = Network.new(victim, network_configs)
            network.run!

            expect(ssh_session.host).to eq(victim.chosen)
          end
        end

        context "with half open connectons" do
          it "will drop a percentage of ESTALISHED packets" do
            expect(ssh_session).to receive(:exec!)
              .with("sudo iptables -A INPUT " \
                    "--source #{dependency_url} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-m conntrack --ctstate ESTABLISHED " \
                    "-J DROP")
              .ordered

            expect(ssh_session).to receive(:exec!)
              .with("sudo iptables -A INPUT " \
                    "--source #{dependency_url_2} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-m conntrack --ctstate ESTABLISHED " \
                    "-J DROP")
              .ordered
              .once

            network = Network.new(
              victim,
              { half_open: true }.merge(network_configs)
            )

            network.run!

            expect(ssh_session.host).to eq(victim.chosen)
          end
        end
      end
    end
  end
end
