# -*- encoding: utf-8 -*-

require File.expand_path("../lib/leeroy_jenkins/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "leeroy_jenkins"
  s.version     = LeeroyJenkins::VERSION
  s.summary     = "Simulates hardware failures in a cluster"
  s.description = %{
  Simulates hardware dedegration by connecting to boxes in your cluster and
  setting up iptables rules and [todo: figure out how to do i/o, cpu, memory].
  Leeroy Jenkins will also manage resetting any changes made.
}.tr("\n", " ")
  s.authors     = ["Kaoru Kohashigawa"]
  s.email       = "dev@kaoruk.com"
  s.files       = `git ls-files bin lib *.md LICENSE`.split("\n")
  s.homepage    = "https://github.com/kaorudev/leeroy_jenkins"
  s.license     = "MIT"
  s.executables << "leeroy_jenkins.sh"

  s.add_dependency "net-ssh", "~> 2.9"

  s.add_development_dependency "pry", "~> 0.10"
  s.add_development_dependency "rspec", "~> 3.5"
  s.add_development_dependency "guard", "~> 2.14"
  s.add_development_dependency "guard-rspec", "~> 4.7"
  s.add_development_dependency "rubocop", "~> 0.48"
  s.add_development_dependency "fabrication", "~> 2.15"
end
