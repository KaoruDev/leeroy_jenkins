require_relative "../../logger"
require_relative "../../victim"
require_relative "./rule"

module LeeroyJenkins
  class Disruption
    class Network
      class BuildRule
        attr_reader :victim, :probability

        def initialize(victim, options = {})
          @victim = victim
          @probability = options[:probability]
        end

        def output_rules
          build_rules(output: true)
        end

        def input_rules
          build_rules(input: true)
        end

        private

        def build_rules(output: false, input: false)
          if victim.all?
            [
              Rule.new(
                output: output,
                probability: probability,
                input: input
              ).build
            ]
          else
            victim.dependencies.map do |dependency|
              Rule.new(
                dependency: dependency,
                input: input,
                output: output,
                probability: probability
              ).build
            end
          end
        end

      end
    end
  end
end
