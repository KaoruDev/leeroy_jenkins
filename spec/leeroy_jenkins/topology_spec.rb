require_relative "../spec_helper"

require "lib/leeroy_jenkins/topology"

module LeeroyJenkins
  RSpec.describe Topology do
    describe ".target_host_url" do
      it "returns what is configured" do
        host_url = "web.example.org"
        topology = Topology.new(target_host_url: host_url)
        expect(topology.target_host_url).to eq(host_url)
      end
    end

    describe ".target_client_url" do
      it "returns what is configured" do
        client_url = "api.example.org"
        topology = Topology.new(target_client_url: client_url)
        expect(topology.target_client_url).to eq(client_url)
      end
    end
  end
end
