require "fling"
require "thor"

module Fling
  # The Fling Command Line Interface
  class CLI < Thor
    desc :setup, "Install Tahoe-LAFS"
    def setup
      require "fling/setup"
      Setup.run
    end

    desc "provision FILE", "Create encrypted Fling configuration"
    def provision(config_file)
      say "Provisioning #{config_file}"

      introducer = ask "What is your introducer FURL? (e.g. pb://...)"
      dropcap    = ask "What is your 'dropcap'? (e.g. URI:DIR2:...)"
      password   = ask "Please enter a password to encrypt the config:", echo: false

      say "\nGenerating encrypted config, please wait..."

      config = Config.generate_encrypted(
        password,
        "introducer"  => introducer,
        "dropcap"     => dropcap,
        "convergence" => Encoding.encode(RbNaCl::Random.random_bytes(32)),
        "salt"        => Encoding.encode(RbNaCl::Random.random_bytes(32))
      )

      File.open(config_file, "w") { |file| file << config }
      say "Created #{config_file}"
    end
  end
end
