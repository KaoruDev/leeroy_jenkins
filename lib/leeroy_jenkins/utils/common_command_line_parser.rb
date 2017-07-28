require "optparse"

require_relative "../logger"
require_relative "../utils"

module LeeroyJenkins
  class Utils
    class CommonCommandLineParser
      attr_reader :configuration, :arguments

      def initialize(arguments)
        @arguments = arguments
        @configuration = {}
      end

      def parse
        parser = configure do |opts, configuration|
          yield(opts, configuration) if block_given?
        end

        parser.parse!(arguments)
        configuration
      rescue OptionParser::InvalidOption => e
        Logger.warn("Opps I'm not sure how to parse option: #{e}")
        Logger.info(parser.help)
        Utils.quit_program(1)
      end

      private

      def configure
        OptionParser.new do |opts|
          opts.on(
            "--reset_in=MINUTES",
            "Number of minutes the disruption will automatically reset"
          ) do |reset_in|
            configuration[:reset_in] = reset_in.to_i
          end

          opts.on(
            "--for_reals",
            "runs the commands being printed out"
          ) do |for_reals|
            configuration[:for_reals] = for_reals
          end

          opts.on(
            "--version",
            "Display the version of Leeroy Jenkins"
          ) do
            configuration[:display_version] = true
          end

          yield(opts, configuration)
        end
      end
    end
  end
end
