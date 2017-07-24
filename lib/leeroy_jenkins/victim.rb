require_relative "./errors"

module LeeroyJenkins
  class Victim
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def target
      unless options[:target]
        raise Error, "Please specify a target"
      end
      # TODO(Kaoru) if no host is target, pick one randomly from topology
    end

    def dependencies
      options[:dependencies] || []
      # TODO(Kaoru) if no client is target,
      # pick one or non randomly from topology
    end

    def all?
      dependencies.empty?
    end
  end
end
