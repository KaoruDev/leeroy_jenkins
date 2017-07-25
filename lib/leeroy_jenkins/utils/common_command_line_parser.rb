require_relative "../logger"

require "optparse"

module LeeroyJenkins
  module Utils
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
      rescue OptionParser::InvalidOption
        Logger.warn("Opps I'm not sure how to parse that option")
        Logger.info(parser.help)
        quit_program(1)
      end

      private

      def configure
        OptionParser.new do |opts|
          opts.on(
            "--version",
            "Display the version of Leeroy Jenkins"
          ) do
            configuration[:display_version] = true
          end

          opts.on(
            "--for_reals",
            "runs the commands being printed out"
          ) do |for_reals|
            configuration[:for_reals] = for_reals
          end

          opts.on(
            "--duration=DURATION",
            "How long before the rules are reset"
          ) do |duration|
            configuration[:duration] = duration.to_i
          end

          yield(opts, configuration)
        end
      end

      # Mostly here so we can stub in specs
      def quit_program(code)
        exit(code)
      end
    end
  end
end
