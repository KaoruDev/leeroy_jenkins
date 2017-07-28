require_relative "../spec_helper.rb"
require "lib/leeroy_jenkins/env"

module LeeroyJenkins
  RSpec.describe Env do
    after(:all) do
      Env.set_to_test!
    end

    describe ".set_to_test!" do
      it "sets Env to test" do
        Env.set_to_test!
        expect(Env.test?).to be_truthy
        expect(Env.live?).to be_falsey
      end
    end

    describe ".set_to_live!" do
      it "sets Env to live" do
        Env.set_to_live!
        expect(Env.test?).to be_falsey
        expect(Env.live?).to be_truthy
      end
    end
  end
end
