require_relative "../../spec_helper"

require "lib/leeroy_jenkins/logger"
require "lib/leeroy_jenkins/utils/common_command_line_parser"

module LeeroyJenkins
  module Utils
    RSpec.describe CommonCommandLineParser do
      describe "#parse" do
        it "will convert arguments into a hash" do
          parser = CommonCommandLineParser.new(%w{
            --duration=5
            --for_reals
          })

          expect(parser.parse).to eq(duration: 5, for_reals: true)
        end

        it "will exit the program if an invalid argument is passed" do
          parser = CommonCommandLineParser.new(%w{
            --duration=5
            --foobar
          })

          expect(parser).to receive(:quit_program).with(1)

          parser.parse

          expect(Logger.test_log).not_to be_empty
        end

        context "when block is given" do
          it "will allow client to add custom options" do
            parser = CommonCommandLineParser.new(%w{
              --duration=5
              --foobar=YOLO
            })

            configs = parser.parse do |opts, configurations|
              opts.on("--foobar=FOOBAR") do |foobar_arg|
                configurations[:foobar] = foobar_arg
              end
            end

            expect(configs).to eq(duration: 5, foobar: "YOLO")
          end
        end
      end
    end
  end
end
