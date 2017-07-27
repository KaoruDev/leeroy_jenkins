require_relative "../logger"
require_relative "../disruption"
require_relative "../fire_drill"
require_relative "../utils/common_command_line_parser"

module LeeroyJenkins
  class FireDrill
    class CommandLineParser
      attr_reader :arguments

      def initialize(arguments)
        @arguments = arguments
      end

      def options
        @options ||= parse
      end

      private

      def parse
        common_parser.parse do |opts, configuration|
          opts.banner = banner

          opts.on(
            "--topology=PATH_TO_TOPOLOGY_FILE",
            "path to yaml file describing your network topology"
          ) do |topology_file_path|
            configuration[:topology_file_path] = topology_file_path
          end

          opts.on(
            "--disruption_limit=DISRUPTION_LIMIT",
            "maximum number of disruption which can occur " \
              "default is #{DEFAULT_DISRUPTIONS}"
          ) do |limit|
            configuration[:disruption_limit] = limit.to_i
          end

          opts.on(
            "--duration=DURATION_IN_HOURS",
            "number of hours from now in which disruptions can " \
              "occur, default is #{DEFAULT_DURATION_HOURS}"
          ) do |duration|
            configuration[:duration] = duration.to_i
          end
        end
      end

      def banner
        %{
Leeroy Jenkins, Fire Drill

Causing gray chaos on your systems since...now!
=================================================

The goal of a Fire Drill is to randomly create dedegrations in your system. By
passing in a yaml file Fire Drill will have knowledge of where your boxes
live and their dependencies. Given a number of hours [--duration] it will create
n number [--disruption_limit] of disruptions. Not to worry though! If your
connection ever gets lost or Leeroy Jenkins crashes there is a fail safe
which will fire in a set amount of minutes [--fail_safe_minutes]. By using
Ubuntu's at command we queue up a reset command in case anything goes wrong. In
addition logs of every command ran and where they were ran will be output in
case you need to stop the disruption before the fail safe is triggered.

Current Disruptions include: #{Disruption::DISRUPTIONS.join(", ")}

Usage: leeroy fire_drill [options]
        }
      end

      def common_parser
        Utils::CommonCommandLineParser.new(arguments)
      end
    end
  end
end
