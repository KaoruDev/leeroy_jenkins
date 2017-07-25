require_relative "./errors"

module LeeroyJenkins
  class Victim

    def initialize(options = {})
      @target = options[:target]
      @dependencies = options[:dependencies]
    end

    def target
      @target.tap do |assigned_target|
        raise Error, "Please specify a target" if assigned_target.nil?
        # TODO(Kaoru) if no host is target, pick one randomly from topology
      end
    end

    def dependencies
      @dependencies || []
      # TODO(Kaoru) if no client is target,
      # pick one or non randomly from topology
    end

    def all?
      dependencies.empty?
    end
  end
end
