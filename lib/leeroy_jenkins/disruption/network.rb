require_relative "../logger"
require_relative "../victim"
require_relative "../ssh_session"
require_relative "./network/build_rule"
require_relative "./network/command_line_parser"

require "net/ssh"

# will degrade network on a particular box
#
# cases:
#   1) drop all packets except on port 22
#   2) drop out ESTABLISHED going packets to foobar host (simulates half-close)
#   3) drop all packets <> specific client
#
# I want it to be random, but also configurable
#

module LeeroyJenkins
  class Disruption
    class Network
      DEFAULT_RULES_FILE = "default_iptables.rules"
      DEFAULT_DURATION = 60
      RESET_RULES_COMMAND =
        "cat ~/#{DEFAULT_RULES_FILE} | sudo iptables-restore"

      attr_accessor :victim, :duration, :half_open, :for_reals, :ssh

      def self.run_with(arguments)
        options = CommandLineParser.new(arguments).options
        victim = Victim.new(options)
        new(victim, options).start
      end

      def initialize(victim, options = {})
        @ssh = options[:ssh]
        @probability = options[:probability]
        @half_open = options[:half_open] || false
        @duration = options[:duration] || DEFAULT_DURATION
        @victim = victim
        @for_reals = options[:for_reals]
      end

      def start
        commands = [
          "sudo iptables-save > ~/#{DEFAULT_RULES_FILE}",
          "echo '#{reset_rules_command}' | at now + #{duration} minutes",
          "echo 'rm ~/#{DEFAULT_RULES_FILE}' | " \
            "at now + #{duration + 1} minutes",
          "sudo iptables -A INPUT -p 22 -j ACCEPT",
          "sudo iptables -A OUTPUT --sport 22 -j ACCEPT",
        ]

        # to simulate half open connects we drop only incoming packets
        unless half_open
          commands.concat(build_rules.output_rules)
        end

        commands.concat(build_rules.input_rules)

        ssh.exec_commands(*commands)
      end

      def clean_up
        ssh.exec!(reset_rules_command)
        ssh.exec!("rm ~/#{DEFAULT_RULES_FILE}")
        close
      end

      def close
        ssh.close
      end

      private

      def reset_rules_command
        RESET_RULES_COMMAND
      end

      def probability
        @probability || rand(0.75...0.95)
      end

      def build_rules
        @build_rule ||= BuildRule.new(
          victim,
          probability: probability,
          half_open: half_open
        )
      end

      def ssh
        @ssh ||= SshSession.new(victim, for_reals: for_reals)
      end
    end
  end
end
