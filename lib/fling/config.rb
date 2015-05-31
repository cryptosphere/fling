require "json"
require "uri"

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

      fail ConfigError, "bad introducer: #{@introducer}" if URI(@introducer).scheme != "pb"
      fail ConfigError, "bad dropcap: #{@dropcap}" unless @dropcap.start_with?("URI:DIR2:")

      %w(convergence salt).each do |key|
        b32_value = options[key]

        begin
          value = Encoding.decode(b32_value)
        rescue
          raise ConfigError, "bad #{key} (base32 error): #{b32_value}"
        end

        fail ConfigError, "bad #{key} (wrong size): #{b32_value}" if value.size != 32
      end
    end
  end
end
