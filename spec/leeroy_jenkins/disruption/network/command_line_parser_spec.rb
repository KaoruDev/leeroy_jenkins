require_relative "../../../spec_helper"

require "lib/leeroy_jenkins/disruption/network/command_line_parser"
require "lib/leeroy_jenkins/utils/common_command_line_parser"

module LeeroyJenkins
  class Disruption
    class Network
      RSpec.describe CommandLineParser do
        describe "#options" do
          it "will convert arguments into a hash" do
            parser = CommandLineParser.new(%w{
              --target=example.com
              --dependencies=foo.example.com,bar.example.com
              --reset_in=5
              --half_open
              --probability=0.8
            })

            expect(parser.options).to eq(
              target: "example.com",
              dependencies: %w{foo.example.com bar.example.com},
              reset_in: 5,
              half_open: true,
              probability: 0.8
            )
          end

          it "will exit program if invalid argument is passed" do
            arguments = %w{
              --target=example.com
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
end
