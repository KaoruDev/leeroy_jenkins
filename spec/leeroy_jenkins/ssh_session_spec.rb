require_relative "../spec_helper"

require "lib/leeroy_jenkins/logger"
require "lib/leeroy_jenkins/ssh_session"
require "lib/leeroy_jenkins/victim"

module LeeroyJenkins
  RSpec.describe SshSession do
    let(:ssh) { double("ssh") }
    let(:victim) { Victim.new(target: "example.com") }

    describe "#exec_commands" do
      it "will just log commands, and not actually run it" do
        expect(ssh).not_to receive(:start)
        expect(ssh).not_to receive(:exec!)

        commands = %{one two three}

        session = SshSession.new(victim)
        session.exec_commands(commands)
        expect(Logger.test_log).to include(*commands)
      end

      context "with for_reals flag" do
        it "it will actually run the commands" do
          received_commands = []
          commands = %w{one two three}

          session = SshSession.new(victim, for_reals: true, ssh: ssh)

          expect(session).to receive(:whoami).and_return("bob_dylan")

          expect(ssh).to receive(:start)
            .with("example.com", "bob_dylan")
            .and_return(ssh)

          expect(ssh).to receive(:exec!) do |arguments|
            received_commands = arguments
          end

          session.exec_commands(commands)

          expect(commands).to eq(received_commands)
        end
      end
    end
  end
end
