require "timeout"

require_relative "../spec_helper"

require "lib/leeroy_jenkins/version"
require "lib/leeroy_jenkins/command_line_runner"
require "lib/leeroy_jenkins/logger"

module LeeroyJenkins
  RSpec.describe CommandLineRunner do
    describe ".run" do
      it "with --version will just print out a version" do
        CommandLineRunner.run(%w{network --version})

        expect(Logger.test_log.pop).to eq("Version: #{VERSION}")
      end

      it "can't find a command will print help" do
        expect(CommandLineRunner).to receive(:print_help)
        CommandLineRunner.run(%w{some_invalid_command --probablity=0.4})
      end

      context "with network command" do
        let(:ssh) { double("ssh") }
        let(:whoami) { "Martha!!!!" }

        before(:each) do
          allow_any_instance_of(SshSession).to receive(:ssh)
            .and_return(ssh)

          allow_any_instance_of(SshSession).to receive(:whoami)
            .and_return(whoami)
        end

        it "will run a network disruption" do
          received_commands = []

          expected_commands = [
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
          ]

          expect(ssh).to receive(:start)
            .with("example.com", whoami)
            .and_return(ssh)

          expect(ssh).to receive(:exec!) { |arg|
            received_commands << arg
          }.exactly(expected_commands.count)

          CommandLineRunner.run(%w{
            network
            --probability=0.9
            -t example.com
            --for_reals
          })

          expected_commands.each_with_index do |rule, idx|
            expect(rule).to eq(received_commands[idx])
          end

          expect(expected_commands.count).to eq(received_commands.count)
        end
      end

      context "with fire_drill command" do
        before do
          allow_any_instance_of(FireDrill).to receive(:pause)
        end

        it "will run a fire drill" do
          allow(Disruption).to receive(:select_random)
            .and_return(Disruption::Network)

          Timeout.timeout(0.5) do
            CommandLineRunner.run(%w{
              fire_drill
              --disruption_limit=1
              --topology=spec/helpers/test_network_topology.yml
            })
          end

          expect(Logger.test_log.count).to be > 0
          iptable_log = Logger.test_log.find do |log|
            log.match(/sudo iptables/)
          end

          expect(iptable_log).not_to be_nil
        end
      end
    end
  end
end
