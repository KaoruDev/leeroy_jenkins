module LeeroyJenkins
  class Engine
    attr_accessor :disruptions, :options

    def initialize(options = {})
      @disruptions = []
      @options = options
    end

    def start
      loop do
        run_iteration
      end
    ensure
      close!
    end

    def run_iteration
      if next_disrupton = select_disruption
        next_disrupton.run!
        disruptions << next_disrupton
      end

      pause
    end

    def select_disruption
      if time_to_disrupt
        Disruption.select_random.new(cluster_topology)
      end
    end

    def close!
      disruptions.each(&:close!)
    end

    private

    def cluster_topology
      # TODO(Kaoru) ClusterTopology can read a specified file, the default file
      # or take in baked in hash.
      @cluster_topology ||=
        options[:cluster_topology] || ClusterTopology.new(options)
    end

    def time_to_disrupt
      rand < 0.01 # 1% chance
    end

    def pause
      sleep 60
    end
  end
end
