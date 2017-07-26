# I want to run n disruptions within x hours

module LeeroyJenkins
  class FireDrill
    attr_accessor :disruptions, :duration, :half_open, :for_reals, :probability

    def initialize(options = {})
      @disruptions = []
      @options = options
      @number_of_disruptions = options[:number_of_disruptions]
      @probability = options[:probability]
      @for_reals = options[:for_reals]
      @duration = options[:duration]
    end

    def start
      loop do
        run_iteration
      end
    ensure
      close!
    end

    def run_iteration
      if time_to_disrupt
        select_disruption.tap do |next_disrupton|
          next_disrupton.run!
          disruptions << next_disrupton
        end
      end

      pause
    end

    def select_disruption
      Disruption.select_random.new(
        victim,
        ssh: ssh,
        probability: probability,
        half_open: half_open,
        duration: duration,
        for_reals: for_reals
      )
    end

    def close!
      disruptions.each(&:close!)
    end

    private

    def time_to_disrupt
      rand < 0.01 # 1% chance
    end

    def victim
      # topology randomly choose victim
    end

    def ssh
      SshSession.new(victim, for_reals: for_reals)
    end

    def pause
      sleep 60
    end
  end
end
