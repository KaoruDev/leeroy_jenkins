require_relative "./disruptions/network.rb"

module LeeroyJenkins
  class Disruption
    DISRUPTIONS = [
      Disruption::Network
    ]

    def self.select_random
      DISRUPTIONS.sample
    end
  end
end
