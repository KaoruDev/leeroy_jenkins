module Factories
  class SshSession
    attr_reader :victim

    def initialize(victim, _options = {})
      @victim = victim
    end

    def exec_commands(*_commands)
      raise "Please stub me!"
    end

    def exec!(_command)
      raise "Please stub me!"
    end

    def close!
      raise "please stub me!"
    end
  end
end
