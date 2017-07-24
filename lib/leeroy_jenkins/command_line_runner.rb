require_relative "./victim"
require_relative "./disruption/network"

module LeeroyJenkins
  class CommandLineRunner
    # TODO: this should really:
    # 1) search for any valid commands
    # 2) then run individual option parsers per disruption
    #    but since I haven't setup how to run stress on boxes network is the
    #    only disruption type atm
    # 3) A lot of what exists in here should belong in Network's command line
    #    parser

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def run
      network.run!
    ensure
      network.close_without_reseting
    end

    private

    def victim
      Victim.new(
        target: options[:target],
        dependencies: options[:dependencies]
      )
    end

    def network
      Disruption::Network.new(
        victim,
        probability: options[:probability],
        duration: options[:duration],
        half_open: options[:half_open],
        for_reals: options[:for_reals]
      )
    end
  end
end
