require_relative "../../../spec_helper"

require "lib/leeroy_jenkins/disruption/network/build_rule"

module LeeroyJenkins
  class Disruption
    class Network
      RSpec.describe BuildRule do
        let(:dependency) { "example.com" }
        let(:dependency_2) { "two.example.com" }
        let(:probability) { 0.74 }

        describe "#output_rules" do
          let(:victim) { Victim.new }
          subject { BuildRule.new(victim).output_rules }

          it "will output 1 rule without a destination" do
            is_expected.to contain_exactly("sudo iptables -A OUTPUT -j DROP")
          end

          context "victim with specific dependencies" do
            let(:victim) {
              Victim.new(dependencies: [dependency, dependency_2])
            }

            it "will contain two rules with each dependency" do
              is_expected.to contain_exactly(
                "sudo iptables -A OUTPUT --destination #{dependency} -j DROP",
                "sudo iptables -A OUTPUT --destination #{dependency_2} -j DROP"
              )
            end

            context "with probability" do
              subject {
                BuildRule.new(victim, probability: probability).output_rules
              }

              it "will contain two rules with probability" do
                is_expected.to contain_exactly(
                  "sudo iptables -A OUTPUT --destination #{dependency} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-j DROP",
                  "sudo iptables -A OUTPUT --destination #{dependency_2} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-j DROP"
                )
              end
            end
          end
        end

        describe "#input_rules" do
          let(:victim) { Victim.new }
          subject { BuildRule.new(victim).input_rules }

          it "will output 1 rule without a source" do
            is_expected.to contain_exactly("sudo iptables -A INPUT -j DROP")
          end

          context "configured to simulate half open connections" do
            subject { BuildRule.new(victim, half_open: true).input_rules }

            it do
              is_expected.to contain_exactly(
                "sudo iptables -A INPUT " \
                "-m conntrack --ctstate ESTABLISHED " \
                "-j DROP"
              )
            end
          end

          context "with a victim with dependencies" do
            let(:victim) {
              Victim.new(dependencies: [dependency, dependency_2])
            }

            it "will contain two rules with each dependency" do
              is_expected.to contain_exactly(
                "sudo iptables -A INPUT --source #{dependency} -j DROP",
                "sudo iptables -A INPUT --source #{dependency_2} -j DROP"
              )
            end

            context "with half_open" do
              subject {
                BuildRule.new(victim, half_open: true).input_rules
              }

              it "will contain two rules with conntrack" do
                is_expected.to contain_exactly(
                  "sudo iptables -A INPUT --source #{dependency} " \
                  "-m conntrack --ctstate ESTABLISHED " \
                  "-j DROP",
                  "sudo iptables -A INPUT --source #{dependency_2} " \
                  "-m conntrack --ctstate ESTABLISHED " \
                  "-j DROP"
                )
              end
            end

            context "with probability" do
              subject {
                BuildRule.new(victim, probability: probability).input_rules
              }

              it "will contain two rules with probability" do
                is_expected.to contain_exactly(
                  "sudo iptables -A INPUT --source #{dependency} " \
                  "-m statistic --mode random --probability #{probability} " \
                  "-j DROP",
                  "sudo iptables -A INPUT --source #{dependency_2} " \
                  "-m statistic --mode random --probability #{probability} " \
                  "-j DROP"
                )
              end
            end
          end
        end
      end
    end
  end
end
