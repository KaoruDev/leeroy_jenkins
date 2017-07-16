$LOAD_PATH << Dir.pwd

require "lib/leeroy_jenkins/env"
require "lib/leeroy_jenkins/logger"
require "rspec"

LeeroyJenkins::Env.set_to_test!

RSpec.configure do |config|
  config.before(:each) do
    LeeroyJenkins::Logger.instance_variable_set("@test_log", [])
  end
end

