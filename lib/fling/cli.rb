require "fling"
require "thor"
require "uri"
require "net/http"
require "yaml"

module Fling
  # The Fling Command Line Interface
  class CLI < Thor
    desc :install, "Install Tahoe-LAFS"
    def install
      require "fling/install"
      Install.run
      say "Now run 'fling config [file or url]' to configure Tahoe-LAFS"
    end

    desc "provision FILE", "Create encrypted Fling configuration"
    def provision(config_file)
      say "Provisioning #{config_file}"

      introducer = ask "What is your introducer FURL? (e.g. pb://...)"
      dropcap    = ask "What is your 'dropcap'? (e.g. URI:DIR2:...)"
      password   = ask "Please enter a password to encrypt the config:", echo: false

      say "\nGenerating encrypted config, please wait..."

      config = Config.encrypt(
        password,
        "introducer"  => introducer,
        "dropcap"     => dropcap,
        "convergence" => Encoding.encode(RbNaCl::Random.random_bytes(32)),
        "salt"        => Encoding.encode(RbNaCl::Random.random_bytes(32))
      )

      File.open(config_file, "w") { |file| file << config }
      say "Created #{config_file}"
    end

    desc "config FILE_OR_URL", "Configure Fling from an encrypted configuration file"
    def config(file_or_uri)
      require "fling/install"

      if file_or_uri[%r{\Ahttps://}]
        uri = URI(file_or_uri)
        ciphertext = Net::HTTP.get(uri)
      elsif file_or_uri[%r{\Ahttp://}] # ಠ_ಠ
        say "Friends don't let friends use http://"
        exit 1
      else # Perhaps it's a file?
        unless File.exist?(file_or_uri)
          say "No such file: #{file_or_uri}"
          exit 1
        end

        ciphertext = File.read(file_or_uri)
      end

      say "Loaded #{file_or_uri}"
      password = ask "Please enter the password to decrypt the config:", echo: false
      say # newline

      begin
        config = Config.decrypt(password, ciphertext)
      rescue Fling::ConfigError => ex
        say "Error: Couldn't decrypt config: #{ex}"
        exit 1
      end

      base_dir   = File.expand_path("~")
      config_dir = File.join(base_dir, ".tahoe")
      if File.exist?(config_dir)
        say "Error: #{config_dir} already exists"
        exit 1
      end

      config.render(config_dir)

      File.open(File.join(base_dir, ".fling.yml"), "w", 0600) do |file|
        file << YAML.dump(salt: config.salt)
      end

      say "Created #{config_dir}!"
      say "Start Tahoe by running 'tahoe start'"
    end
  end
end
