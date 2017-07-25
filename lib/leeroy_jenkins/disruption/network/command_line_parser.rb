require_relative "../../logger"
require_relative "../network"
require_relative "../../utils/common_command_line_parser"

module LeeroyJenkins
  class Disruption
    class Network
      class CommandLineParser
        attr_reader :arguments

        def initialize(arguments)
          @arguments = arguments
        end

        def options
          @options ||= parse
        end

        private

        # rubocop:disable Metrics/BlockLength
        def parse
          common_parser.parse do |opts, configuration|
            opts.banner = banner

            opts.on(
              "--half_open",
              "Simulates half open networks"
            ) do |half_open|
              configuration[:half_open] = half_open
            end

            opts.on(
              "--probability=PROBABLITIY",
              "Probability of droped packets, " \
                "a random percentage between 0.75 and 0.9 will be chosen"
            ) do |probability|
              if 1 < probability.to_f
                LeeroyJenkins::Logger.warn(
                  "Probability may not be greater than 1, setting it to 1"
                )
                probability = 1.0
              end

              configuration[:probability] = probability.to_f
            end

            opts.on(
              "-t target",
              "--target=SERVER_URL",
              "URL or ip address of the box where disruptions will be created"
            ) do |target|
              configuration[:target] = target
            end

            opts.on(
              "--dependencies=DEPENDENCIES",
              "Coma seperate list of network dependencies"
            ) do |dependencies|
              configuration[:dependencies] = dependencies.split(",")
            end
          end
        end
        # rubocop:enable Metrics/BlockLength

        def banner
          %{
Leeroy Jenkins, Network Disruption

Causing havoc on your Topology!
=================================================

I'll configure packets to be dropped on a target box by setting
up iptables rules. Don't worry I'll clean up after myself based on the duration
you configure or the default of #{Network::DEFAULT_DURATION} minutes. You can
manually reset your rules by running `#{Network::RESET_RULES_COMMAND}`

Usage: leeroy network [options] -t example.com
          }
        end

        def common_parser
          Utils::CommonCommandLineParser.new(arguments)
        end
      end
    end
  end
end
