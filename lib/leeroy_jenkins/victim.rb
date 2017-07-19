module LeeroyJenkins
  class Victim
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def chosen
      options[:chosen]
      # TODO(Kaoru) if no host is chosen, pick one randomly from topology
    end

    def dependencies
      options[:dependencies] || []
      # TODO(Kaoru) if no client is chosen,
      # pick one or non randomly from topology
    end

    def all?
      dependencies.empty?
    end
  end
end
