require_relative "../logger.rb"
require_relative "../victim.rb"
require_relative "./network/build_rule.rb"
require_relative "../../../spec/factories/ssh_session"

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

      attr_accessor :victim, :duration, :half_open, :for_reals

      def initialize(victim, options = {})
        # TODO: I should change how we use options, it's easier to read if i
        # destruct it in initialize instead of all over the place

        @ssh = options[:ssh]
        @probability = options[:probability]
        @half_open = options[:half_open] || false
        @duration = options[:duration] || 60
        @victim = victim
        @for_reals = options[:for_reals]
      end

      def run!
        log_dry_run_message

        save_default_rules
        queue_reset_rules
        ensure_ssh_connections_are_allowed

        # to simulate half open connects we drop only incoming packets
        unless half_open
          build_rules.output_rules.each do |rule|
            ssh_exec!(rule)
          end
        end

        build_rules.input_rules.each do |rule|
          ssh_exec!(rule)
        end

        log_encourage_message
      end

      def close!
        ssh_exec!("sudo service iptables restart")
        ssh_session.close
      rescue IOException
        Logger.warn("ssh session already closed!")
      end

      private

      def ensure_ssh_connections_are_allowed
        ssh_exec!("sudo iptables -A INPUT -p 22 -j ACCEPT")
        ssh_exec!("sudo iptables -A OUTPUT --sport 22 -j ACCEPT")
      end

      def save_default_rules
        ssh_exec!("sudo iptables-save > ~/#{DEFAULT_RULES_FILE}")
      end

      def queue_reset_rules
        ssh_exec!("echo 'cat ~/#{DEFAULT_RULES_FILE} | " \
                  "sudo iptables-restore' " \
                  "| at now + #{duration} minutes")
      end

      def ssh_exec!(command)
        if for_reals
          Logger.log("[TARGET: #{victim.target}] Running #{command}")
          # TODO(Kaoru): Log the results in verbose mode
          ssh_session.exec!(command)
        else
          Logger.log(command)
        end
      end

      def ssh_session
        return @ssh_session if @ssh_session

        Logger.log("Establishing ssh connection with #{victim.target}")
        @ssh_session = ssh.start(victim.target, whoami).tap do
          Logger.log("ssh successfully connected! #{victim.target}")
        end
      end

      def ssh
        @ssh ||= Net::SSH
      end

      def probability
        @probability || rand(0.75...0.95)
      end

      def whoami
        `whoami`.chomp
      end

      def build_rules
        @build_rule ||= BuildRule.new(
          victim,
          probability: probability,
          half_open: half_open
        )
      end

      def log_dry_run_message
        if for_reals
          Logger.log("\e[31mOk running these commands on" \
                    " #{victim.target} for reals!\e[0m")
        else
          Logger.log("I'll run these commands on #{victim.target} " \
                     "when you pass in the \e[31m--for_reals\e[0m flag. ")
        end

        Logger.log("===========================================")
      end

      def log_encourage_message
        unless for_reals
          Logger.log("Come on already! Pass the \e[31m--for_reals \e[0mflag" \
                      " and let me play!!!!")
        end
      end
    end
  end
end
