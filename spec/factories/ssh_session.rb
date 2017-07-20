module Factories
  class SshSession
    attr_reader :state, :host

    def initialize
      self.state = :opened
    end

    def start(target_host, _whoami)
      self.host = target_host
      self
    end

    def exec!(_message)
      raise "Please override me!"
    end

    def close
      self.state = :closed
    end

    private

    attr_writer :state, :host

  end
end
