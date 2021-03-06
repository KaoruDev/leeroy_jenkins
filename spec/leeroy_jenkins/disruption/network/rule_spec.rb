require_relative "../../../spec_helper"

require "lib/leeroy_jenkins/disruption/network/rule"

module LeeroyJenkins
  class Disruption
    class Network
      RSpec.describe Rule do
        let(:dependency) { "db.example.com" }
        let(:probability) { 0.8 }

        describe "#build" do
          it "will raise an error if input or output are not configured" do
            expect { Rule.new.build }.to raise_error(RuntimeError)
          end

          context "as an output rule" do
            subject { Rule.new(output: true).build }

            it { is_expected.to eq("sudo iptables -A OUTPUT -j DROP") }

            context "with a configured probability" do
              subject {
                Rule.new(output: true, probability: probability).build
              }

              it do
                is_expected.to eq(
                  "sudo iptables -A OUTPUT " \
                  "-m statistic --mode random --probability #{probability} " \
                  "-j DROP"
                )
              end
            end

            context "with specific dependency" do
              subject { Rule.new(output: true, dependency: dependency).build }

              it do
                is_expected.to eq(
                  "sudo iptables -A OUTPUT --destination #{dependency} -j DROP"
                )
              end

              context "and a configured probability" do
                subject do
                  Rule.new(
                    output: true,
                    probability: probability,
                    dependency: dependency
                  ).build
                end

                it do
                  is_expected.to eq(
                    "sudo iptables -A OUTPUT " \
                    "--destination #{dependency} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-j DROP"
                  )
                end
              end
            end
          end

          context "as an input rule" do
            subject { Rule.new(input: true).build }

            it { is_expected.to eq("sudo iptables -A INPUT -j DROP") }

            context "with a configured probability" do
              subject { Rule.new(input: true, probability: probability).build }

              it do
                is_expected.to eq(
                  "sudo iptables -A INPUT " \
                  "-m statistic --mode random --probability #{probability} " \
                  "-j DROP"
                )
              end
            end

            context "with specific dependency" do
              subject { Rule.new(output: true, dependency: dependency).build }

              it do
                is_expected.to eq(
                  "sudo iptables -A OUTPUT --destination #{dependency} -j DROP"
                )
              end

              context "and a configured probability" do
                subject do
                  Rule.new(
                    output: true,
                    probability: probability,
                    dependency: dependency
                  ).build
                end

                it do
                  is_expected.to eq(
                    "sudo iptables -A OUTPUT " \
                    "--destination #{dependency} " \
                    "-m statistic --mode random --probability #{probability} " \
                    "-j DROP"
                  )
                end
              end
            end
          end

          context "simulating half open connections with a dependency" do
            subject {
              Rule.new(
                input: true,
                half_open: true,
                dependency: dependency
              ).build
            }

            it do
              is_expected.to eq(
                "sudo iptables -A INPUT --source #{dependency} " \
                "-m conntrack --ctstate ESTABLISHED " \
                "-j DROP"
              )
            end
          end
        end
      end
    end
  end
end
