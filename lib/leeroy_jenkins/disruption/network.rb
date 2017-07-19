require_relative "../logger.rb"
require_relative "../victim.rb"
require_relative "./network/build_rule.rb"

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
      attr_accessor :victim, :topology, :options

      def initialize(victim, options = {})
        @options = options
        @victim = victim
      end

      def run!
        ssh_session.exec!(reset_iptables_in(options[:duration]))
        ensure_ssh_connections_are_allowed

        # to simulate half open connects we drop only incoming packets
        unless options[:half_open]
          build_rules.output_rules.each do |rule|
            ssh_session.exec!(rule)
          end
        end

        build_rules.input_rules.each do |rule|
          ssh_session.exec!(rule)
        end
      end

      def close!
        ssh_session.exec!("sudo service iptables restart")
        ssh_session.close
      rescue IOException
        Logger.warn("ssh session already closed!")
      end

      private

      def ensure_ssh_connections_are_allowed
        ssh_session.exec!("sudo iptables -A INPUT -p 22 -J ACCEPT")
        ssh_session.exec!("sudo iptables -A OUTPUT --sport 22 -J ACCEPT")
      end

      def reset_iptables_in(minutes = nil)
        minutes ||= 60
        "echo 'sudo service iptables restart' | at now + #{minutes} minutes"
      end

      def ssh_session
        @ssh_session ||= start_ssh_session
      end

      def start_ssh_session
        ssh.start(victim.target, whoami)
      end

      def ssh
        @ssh ||= options[:ssh] # || Net::SSH
      end

      def probability
        @probability ||= options[:probability] || rand(0.75...0.95)
      end

      def whoami
        `whoami`.chomp
      end

      def build_rules
        @build_rule ||= BuildRule.new(
          victim,
          probability: probability,
          half_open: options[:half_open]
        )
      end
    end
  end
end
