require_relative "../../logger"
require_relative "../../victim"
require_relative "./rule"

module LeeroyJenkins
  class Disruption
    class Network
      class BuildRule
        attr_reader :victim, :probability, :options

        def initialize(victim, options = {})
          @victim = victim
          @probability = options[:probability]
          @options = options
        end

        def output_rules
          build_rules(output: true)
        end

        def input_rules
          build_rules(input: true)
        end

        private

        def build_rules(configs = {})
          if victim.all?
            [Rule.new(build_rule_configs(nil, configs)).build]
          else
            victim.dependencies.map do |dependency|
              Rule.new(build_rule_configs(dependency, configs)).build
            end
          end
        end

        def build_rule_configs(dependency = nil, custom_configs = {})
          {
            dependency: dependency,
            half_open: options[:half_open],
            probability: probability
          }.merge(custom_configs)
        end
      end
    end
  end
end
