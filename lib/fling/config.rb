require "json"

module Fling
  # Configuration for the local Tahoe cluster
  class Config
    CONFIG_KEYS = %w(introducer convergence salt dropcap)
    attr_reader(*CONFIG_KEYS)

    # Load configuration from a JSON file
    def self.load_json(file)
      from_json File.read(file)
    end

    # Parse configuration from JSON
    def self.from_json(json)
      new(JSON.parse(json))
    end

    def initialize(options = {})
      CONFIG_KEYS.each do |key|
        fail ArgumentError, "missing key: #{key}" unless options[key]
        instance_variable_set("@#{key}", options[key])
      end
    end
  end
end
