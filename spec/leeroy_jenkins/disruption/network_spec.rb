require_relative "../../spec_helper"
require "spec/factories/ssh_session"

require "lib/leeroy_jenkins/disruption/network"

module LeeroyJenkins
  class Disruption
    RSpec.describe Network do
      let(:ssh_session) { double("ssh_session") }
      let(:network_configs) {
        { ssh: ssh_session, probability: probability, for_reals: true }
      }
      let(:dependency_url) { "api.example.org" }
      let(:dependency_url_2) { "api2.example.org" }
      let(:dependencies) { [dependency_url, dependency_url_2] }
      let(:target) { "web.example.org" }
      let(:probability) { 0.76 }

      let(:victim) {
        Victim.new(target: target, dependencies: dependencies)
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
        let(:commands) {
          [
            "sudo iptables-save > ~/default_iptables.rules",
            "echo 'cat ~/default_iptables.rules | sudo iptables-restore' " \
                  "| at now + 60 minutes",
            "echo 'rm ~/default_iptables.rules' | at now + 61 minutes",
            "sudo iptables -A INPUT -p 22 -j ACCEPT",
            "sudo iptables -A OUTPUT --sport 22 -j ACCEPT",
          ]
        }

        context "with a victim with no targets" do
          let(:victim) { Victim.new(target: target) }

          it "will drop a percentage of all outgoing / incoming packets" do
            expected_commands = commands.dup
            received_commands = nil

            expected_commands.push(
              "sudo iptables -A OUTPUT " \
                "-m statistic --mode random --probability #{probability} " \
                "-j DROP"
            )

            expected_commands.push(
              "sudo iptables -A INPUT " \
                "-m statistic --mode random --probability #{probability} " \
                "-j DROP"
            )

            expect(ssh_session).to receive(:exec_commands) { |*args|
              received_commands = args
            }

            network = Network.new(victim, network_configs)
            network.run!

            # Order of commands matter
            expect(expected_commands).to eq(received_commands)
          end
        end

        context "with a victim with 2 dependencies" do
          it "will drop a percentage of out going and incoming " \
             "packets to clients " do
            expected_commands = commands.dup
            received_commands = nil

            expected_commands.push(
              "sudo iptables -A OUTPUT " \
                "--destination #{dependency_url} " \
                "-m statistic --mode random --probability #{probability} " \
                "-j DROP"
            )

            expected_commands.push(
              "sudo iptables -A OUTPUT " \
                "--destination #{dependency_url_2} " \
                "-m statistic --mode random --probability #{probability} " \
                "-j DROP"
            )

            # drops packets outgoing to client
            expected_commands.push(
              "sudo iptables -A INPUT " \
                "--source #{dependency_url} " \
                "-m statistic --mode random --probability #{probability} " \
                "-j DROP"
            )

            expected_commands.push(
              "sudo iptables -A INPUT " \
                "--source #{dependency_url_2} " \
                "-m statistic --mode random --probability #{probability} " \
                "-j DROP"
            )

            expect(ssh_session).to receive(:exec_commands) { |*args|
              received_commands = args
            }.once

            network = Network.new(victim, network_configs)
            network.run!

            # Order of commands matter
            expect(expected_commands).to eq(received_commands)
          end
        end

        context "with half open connectons" do
          it "will drop a percentage of ESTALISHED packets" do
            received_commands = nil
            expected_commands = commands.dup

            expected_commands.push(
              "sudo iptables -A INPUT " \
                "--source #{dependency_url} " \
                "-m statistic --mode random --probability #{probability} " \
                "-m conntrack --ctstate ESTABLISHED " \
                "-j DROP"
            )

            expected_commands.push(
              "sudo iptables -A INPUT " \
                "--source #{dependency_url_2} " \
                "-m statistic --mode random --probability #{probability} " \
                "-m conntrack --ctstate ESTABLISHED " \
                "-j DROP"
            )

            expect(ssh_session).to receive(:exec_commands) { |*args|
              received_commands = args
            }.once

            network = Network.new(
              victim,
              { half_open: true }.merge(network_configs)
            )

            network.run!

            # Order of commands matter
            expect(expected_commands).to eq(received_commands)
          end
        end
      end
    end
  end
end
