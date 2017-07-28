require_relative "../spec_helper"

require "lib/leeroy_jenkins/topology"

module LeeroyJenkins
  RSpec.describe Topology do
    let(:test_file) { "spec/helpers/test_network_topology.yml" }

    describe "#choose_random_victim" do
      it "will choose a victim at random" do
        victim = Topology.new(test_file).choose_random_victim

        expect(victim.target).not_to be_nil
        expect(victim.dependencies).to be_an(Array)
      end

      it "will return a random victim based on the topology graph" do
        topology = Topology.new(test_file)
        allow(topology).to receive(:random_victim_name).and_return("web")
        allow(topology).to receive(:random_dependencies).and_return(%w{
          api
          db.example.com
        })

        victim = topology.choose_random_victim

        expect(victim.target).to eq("web.example.com")
        expect(%w{
          api.example.com
          db.example.com
        }).to contain_exactly(*victim.dependencies)
      end

      context "invalid topology file" do
        it "without \"node\" will raise an error" do
          topology = Topology.new(test_file)

          allow(topology).to receive(:load_yaml_file)
            .and_return(
              "node" => { # typo, should be nodes
                "web" => {
                  "uri" => "web.example.com"
                }
              }
            )

          expect {
            topology.choose_random_victim
          }.to raise_error(
            Error,
            "Please make sure your yaml file " \
              "has a property called \"nodes\""
          )
        end

        it "with a node without a uri property" do
          topology = Topology.new(test_file)

          allow(topology).to receive(:load_yaml_file)
            .and_return(
              "nodes" => {
                "web" => {}
              }
            )

          expect {
            topology.choose_random_victim
          }.to raise_error(Error, "Please make sure node web has a uri")
        end
      end

    end
  end
end
