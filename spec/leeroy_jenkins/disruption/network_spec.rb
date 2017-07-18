require_relative "../../spec_helper"
require "spec/factories/ssh_session"

require "lib/leeroy_jenkins/disruption/network"

module LeeroyJenkins
  class Disruption
    RSpec.describe Network do
      let(:ssh_session) { Factories::SshSession.new }
      let(:network_configs) {
        { ssh: ssh_session, probability: 0.75 }
      }
      let(:client_url) { "api.example.org" }
      let(:host_url) { "web.example.org" }

      let(:topology) {
        Topology.new(
          target_client_url: client_url,
          target_host_url: host_url
        )
      }

      describe ".probability" do
        it "will return whatever it is set to" do
          network = Network.new(topology, probability: 0.1)
          expect(network.send(:probability)).to eq(0.1)
          expect(network.send(:probability)).to eq(0.1)
          expect(network.send(:probability)).to eq(0.1)
          expect(network.send(:probability)).to eq(0.1)
        end

        it "will return a float between a range" do
          network = Network.new(topology)
          expect(network.send(:probability)).to be_within(0.75).of(0.95)
          expect(network.send(:probability)).to be_within(0.75).of(0.95)
          expect(network.send(:probability)).to be_within(0.75).of(0.95)
          expect(network.send(:probability)).to be_within(0.75).of(0.95)
        end
      end

      describe ".run!" do
        context "dedegration type: half-closed" do
          context "when host and client are specified" do
            xit "will drop a percentage of out going packets to clients " do
              expect(ssh_session).to receive(:exec!)
                .with("echo 'sudo service iptables restart' " \
                      "| at now + 60 minutes").ordered

              # accepts all ssh connections
              expect(ssh_session).to receive(:exec!)
                .with("sudo iptables -A INPUT -p 22 -J ACCEPT").ordered

              expect(ssh_session).to receive(:exec!)
                .with("sudo iptables -A OUTPUT --sport 22 -J ACCEPT").ordered

              # drops packets outgoing to client
              expect(ssh_session).to receive(:exec!)
                .with("sudo iptables -A OUTPUT -d #{client_url} " \
                      "-m statistic --mode random --probability 0.75 " \
                      "-J DROP").ordered

              network = Network.new(topology, network_configs)
              network.run!

              expect(ssh_session.host).to eq(topology.target_host_url)
            end
          end
        end
      end
    end
  end
end
