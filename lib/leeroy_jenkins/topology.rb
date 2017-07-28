require "Psych"

require_relative "./victim"
require_relative "./errors"

module LeeroyJenkins
  class Topology
    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path
    end

    def choose_random_victim
      target = nodes[random_victim_name]
      dependency_names = random_dependencies(target)
      dependency_uris = find_uris_of(dependency_names)

      Victim.new(
        target: target["uri"],
        dependencies: dependency_uris
      )
    end

    private

    def random_victim_name
      nodes.keys.sample
    end

    def random_dependencies(target)
      dependencies = target["dependencies"] || []
      dependencies.sample(dependencies.count)
    end

    def find_uris_of(dependency_names)
      dependency_names.map do |name|
        if node = nodes[name]
          node["uri"]
        else
          name
        end
      end
    end

    def nodes
      graph["nodes"]
    end

    def graph
      return @graph if @graph
      @graph = load_yaml_file
      validate_graph!
      @graph
    end

    def load_yaml_file
      if file_path.nil?
        raise Error, "Please provide a path to your topology file"
      end
      Psych.safe_load(File.read(file_path))
    rescue Psych::SyntaxError => e
      Logger.error("Unable to parse #{file_path}")
      Logger.error(e.backtrace.join("\n"))
    end

    def validate_graph!
      if nodes.nil?
        raise Error, "Please make sure your yaml file has a " \
          "property called \"nodes\""
      end

      nodes.each do |name, node|
        if !node.is_a?(Hash) || node["uri"].nil? || node["uri"] == ""
          raise Error, "Please make sure node #{name} has a uri"
        end
      end
    end
  end
end
