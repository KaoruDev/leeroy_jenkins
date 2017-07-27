require_relative "../../spec_helper"

require "lib/leeroy_jenkins/fire_drill"

module LeeroyJenkins
  class FireDrill
    RSpec.describe CommandLineParser do
      describe "#options" do
        it "will convert arguments into a hash" do
          parser = CommandLineParser.new(%w{
            --topology=topology.yml
            --disruption_limit=5
            --duration=6
          })

          expect(parser.options).to eq(
            topology_file_path: "topology.yml",
            duration: 6,
            disruption_limit: 5
          )
        end

        it "will exit program if invalid argument is passed" do
          arguments = %w{
            --topology=topology.yml
            --danger
          }

          parser = CommandLineParser.new(arguments)
          common_parser = Utils::CommonCommandLineParser.new(arguments)

          expect(Utils).to receive(:quit_program).with(1)
          expect(parser).to receive(:common_parser).and_return(common_parser)

          parser.options
        end
      end
    end
  end
end
