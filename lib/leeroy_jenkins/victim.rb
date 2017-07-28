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
      end
    end

    def dependencies
      @dependencies || []
    end

    def all?
      dependencies.empty?
    end
  end
end
