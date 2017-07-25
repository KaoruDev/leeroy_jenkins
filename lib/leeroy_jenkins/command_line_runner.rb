require_relative "./disruption/network"
require_relative "./version"

module LeeroyJenkins
  class CommandLineRunner
    # TODO: this should really:
    # 1) search for any valid commands
    # 2) then run individual option parsers per disruption
    #    but since I haven't setup how to run stress on boxes network is the
    #    only disruption type atm
    # 3) A lot of what exists in here should belong in Network's command line
    #    parser

    VALID_COMMANDS = %w{
      network
      fire_drill
    }

    VERSION_FLAG = "--version"

    def run
      if ARGV.any? { |arg| arg == VERSION_FLAG }
        Logger.info(VERSION)
      else
        ARGV.find { |arg| VALID_COMMANDS.include?(arg) }.tap do |command|
          CommandLineArgumentParser.print_help if command.nil?
        end
      end
    end

  end
end
