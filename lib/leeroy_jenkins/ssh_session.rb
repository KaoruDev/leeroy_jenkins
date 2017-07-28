require_relative "./logger.rb"

require "net/ssh"

module LeeroyJenkins
  class SshSession

    attr_reader :victim, :for_reals

    def initialize(victim, options = {})
      @victim = victim
      @for_reals = options[:for_reals]
      @ssh = options[:ssh]
    end

    def exec_commands(*commands)
      log_pre_messages
      commands.each do |command|
        exec!(command)
      end
    end

    def exec!(command)
      if for_reals
        Logger.info("[TARGET: #{victim.target}] Running #{command}")

        # TODO(Kaoru): Log the results in verbose mode
        connection.exec!(command)
      else
        Logger.info(command)
      end
    end

    def close
      if for_reals
        connection.close
        Logger.info("Successfully disconnected from #{victim.target}")
      end
    end

    private

    def log_pre_messages
      if for_reals
        Logger.info("\e[31mOk running these commands on" \
                  " #{victim.target} for reals!\e[0m")
      else
        Logger.info("Printing commands I would have run on #{victim.target} " \
                   "had you passed in the \e[31m--for_reals\e[0m flag, wuss.")
      end

      Logger.info("===========================================")
    end

    def connection
      return @connection if @connection

      Logger.info("Establishing ssh connection with #{victim.target}")
      @connection = ssh.start(victim.target, whoami).tap do
        Logger.info("ssh successfully connected! #{victim.target}")
      end
    end

    def ssh
      @ssh || Net::SSH
    end

    def whoami
      `whoami`.chomp
    end
  end
end
