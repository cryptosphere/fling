require "json"
require "uri"
require "base64"
require "rbnacl"
require "fileutils"
require "erb"

module Fling
  # Configuration for the local Tahoe cluster
  class Config
    BEGIN_MARKER = "-----BEGIN ENCRYPTED FLING CONFIGURATION-----\n"
    END_MARKER   = "------END ENCRYPTED FLING CONFIGURATION------"

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

    # Generate an encrypted configuration
    def self.encrypt(password, config)
      ciphertext = Box.encrypt(password, generate_json(config))
      BEGIN_MARKER + Base64.encode64(ciphertext) + END_MARKER
    end

    # Decrypt an encrypted configuration
    def self.decrypt(password, ciphertext)
      matches = ciphertext.match(/#{BEGIN_MARKER}(.*)#{END_MARKER}/m)
      fail ConfigError, "couldn't find fling configuration (corrupted file?)" unless matches

      new(Box.decrypt(password, Base64.decode64(matches[1])))
    rescue RbNaCl::CryptoError # bad password
      fail ConfigError, "couldn't decrypt configuration (corrupted file or bad password?)"
    end

    # Generate a JSON configuration
    def self.generate_json(config)
      new(config).as_json
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

    # Render the configuration to the given path
    def render(path)
      require "fling/setup"

      tahoe_bin = File.expand_path("~/#{Fling::Setup::TAHOE_DIR}/bin/tahoe")
      system "#{tahoe_bin} create-node > /dev/null"

      @nickname = `whoami`
      @introducer_furl = introducer

      config_template = File.expand_path("../../../templates/tahoe.cfg.erb", __FILE__)
      tahoe_config = ERB.new(File.read(config_template)).result(binding)

      File.open(File.join(path, "tahoe.cfg"), "w", 0600) { |file| file << tahoe_config }

      secrets = File.join(path, "private")
      File.open(File.join(secrets, "convergence"), "w", 0600) { |file| file << convergence }
      File.open(File.join(secrets, "aliases"), "w", 0600) { |file| file << "dropcap: #{dropcap}" }
    end

    def as_json
      {
        introducer:  introducer,
        convergence: convergence,
        salt:        salt,
        dropcap:     dropcap
      }
    end
  end
end
