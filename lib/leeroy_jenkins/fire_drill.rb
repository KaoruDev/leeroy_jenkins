require "timeout"
require_relative "./disruption"
require_relative "./fire_drill/command_line_parser"
require_relative "./topology"

module LeeroyJenkins
  class FireDrill
    attr_accessor :disruptions,
      :duration,
      :reset_in,
      :for_reals,
      :disruption_limit,
      :start_time,
      :topology_file_path

    DEFAULT_DISRUPTIONS = 5
    DEFAULT_DURATION_HOURS = 6

    def self.run_with(arguments)
      options = CommandLineParser.new(arguments).options
      new(options).start
    end

    def initialize(options = {})
      @disruptions = []
      @for_reals = options[:for_reals]
      @disruption_limit = options[:disruption_limit] || DEFAULT_DISRUPTIONS
      @duration = options[:duration] || DEFAULT_DURATION_HOURS
      @topology_file_path = options[:topology_file_path]
      @reset_in = options[:reset_in]
    end

    def start
      @start_time = now
      Timeout.timeout(duration_in_seconds) do # fail safe
        run_iteration while running?
      end
    ensure
      disruptions.each(&:close)
    end

    def run_iteration
      if time_to_disrupt
        select_disruption.tap do |next_disrupton|
          next_disrupton.start
          disruptions << next_disrupton
        end
      end

      pause
    end

    def select_disruption
      Disruption.select_random.new(
        victim,
        for_reals: for_reals,
        reset_in: reset_in
      )
    end

    private

    def victim
      topology.choose_random_victim
    end

    def topology
      @topology ||= Topology.new(topology_file_path)
    end

    def running?
      disruptions.count < disruption_limit &&
        start_time + duration_in_seconds > now
    end

    def time_to_disrupt
      rand < 0.01 # 1% chance
    end

    def duration_in_seconds
      duration * 60 * 60
    end

    def now
      Time.now.to_i
    end

    def pause
      #sleep 60
    end
  end
end
