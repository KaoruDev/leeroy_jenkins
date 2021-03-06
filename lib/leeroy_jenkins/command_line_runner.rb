require_relative "./disruption/network"
require_relative "./fire_drill"
require_relative "./version"
require_relative "./errors"
require_relative "./utils"

module LeeroyJenkins
  class CommandLineRunner
    VALID_COMMANDS = {
      network: LeeroyJenkins::Disruption::Network,
      fire_drill: LeeroyJenkins::FireDrill
    }

    VERSION_FLAG = "--version"

    def self.run(arguments)
      if arguments.any? { |arg| arg == VERSION_FLAG }
        Logger.info("Version: #{VERSION}")
      else
        arguments
          .find { |arg| VALID_COMMANDS.keys.include?(arg.to_sym) }
          .tap do |command|
            return print_help if command.nil?

            VALID_COMMANDS[command.to_sym].run_with(arguments)
          end
      end
    rescue Error => e
      Logger.error(e)
      Logger.error(e.backtrace.join("\n"))
      Utils.quit_program(1)
    end

    def self.print_help
      # TODO print something meaningful woot!
      Logger.info("TODO write help shit")
      Utils.quit_program(1)
    end
  end
end
