module Factories
  class SshSession
    attr_reader :state, :list_of_commands, :host

    def initialize
      state = :opened
      list_of_commands = []
    end

    def start(target_host, whoami)
      host = target_host
      self
    end

    def exec!(message)
      raise "please stub me"
    end

    def close
      state = :closed
    end

    private

    attr_writer :state, :host

  end
end
