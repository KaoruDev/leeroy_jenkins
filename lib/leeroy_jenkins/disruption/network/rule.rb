require_relative "../../logger"

module LeeroyJenkins
  class Disruption
    class Network
      class Rule
        ACTIONS = %i{
          add_rule_chain
          add_dependency
          add_probability
          add_state
          add_target
        }

        attr_reader :configs

        def initialize(configs = {})
          @configs = configs
        end

        def build
          validate_direction!
          ACTIONS.reduce("sudo iptables") do |rule, action|
            send(action, rule)
          end
        end

        private

        def add_rule_chain(rule)
          "#{rule} -A #{rule_chain}"
        end

        def add_dependency(rule)
          if dependency = configs[:dependency]
            "#{rule} #{dependency_flag} #{dependency}"
          else
            rule
          end
        end

        def add_probability(rule)
          if probability = configs[:probability]
            "#{rule} -m statistic --mode random --probability #{probability}"
          else
            rule
          end
        end

        def add_state(rule)
          if configs[:half_open]
            "#{rule} -m conntrack --ctstate ESTABLISHED"
          else
            rule
          end
        end

        def add_target(rule)
          "#{rule} -J DROP"
        end

        def rule_chain
          if configs[:input]
            "INPUT"
          elsif configs[:output]
            "OUTPUT"
          end
        end

        def dependency_flag
          if configs[:input]
            "--source"
          elsif configs[:output]
            "--destination"
          end
        end

        def validate_direction!
          if configs[:input].nil? && configs[:output].nil?
            raise "Please tell me if I'm an input or output rule!"
          end
        end
      end
    end
  end
end
