module LeeroyJenkins
  class Topology
    attr_writer :config, :target_host_url, :target_client_url

    def initialize(options = {})
      configs = options[:configs]
      self.target_host_url = options[:target_host_url]
      self.target_client_url = options[:target_client_url]
    end

    def target_host_url
      return @target_host_url if @target_host_url
      target_host = architecture.keys.sample
      @target_host_url = nodes[target_host].sample
    end

    def target_client_url
      return @target_client_url if @target_client_url
      # TODO(Kaoru): choosing a specific client is a bit more diffcult, need to
      # revisit
      dependency = %w{downstream upstream}.sample
      client = architecture[target_host][dependency].sample
      @target_client_url = nodes[client]
    end

    private

    def architecture
      configs["architecture"] || {}
    end

    def nodes
      return @nodes if @nodes

      if configs["nodes"].nil?
        Logger.error("please configure nodes")
        raise "nodes must not be empty"
      end

      @nodes ||= configs["nodes"]
    end

    def configs
      @configs ||= read_configs
    end

    def read_configs
      # TODO(Kaoru): yaml read architecture file
      {}
    end
  end
end
