require "json"
require "rbnacl/libsodium"

module Fling
  # Simple encryption with password-derived keys
  class Box
    attr_reader :key, :fingerprint

    def initialize(password, salt, options = {})
      opts = {
        scrypt_opslimit: 2**25,
        scrypt_memlimit: 2**30
      }.merge(options)

      @key = RbNaCl::PasswordHash.scrypt(
        password.force_encoding("BINARY"),
        salt.force_encoding("BINARY"),
        opts[:scrypt_opslimit],
        opts[:scrypt_memlimit],
        RbNaCl::SecretBox::KEYBYTES
      )

      @fingerprint = Encoding.encode(RbNaCl::Hash.blake2b(@key, digest_size: 32))
    end

    def encrypt(data = {})
      # Ensure data is a simple flat hash of strings
      data = data.map do |key, value|
        fail TypeError, "bad key: #{key.inspect}" unless key.is_a?(String) || key.is_a?(Symbol)
        fail TypeError, "bad value: #{value.inspect}" unless value.is_a?(String)
        [key.to_s, value]
      end.flatten

      json = JSON.generate(Hash[*data])
      encryption_box.encrypt(json.force_encoding("BINARY"))
    end

    def decrypt(ciphertext)
      json = encryption_box.decrypt(ciphertext.force_encoding("BINARY"))
      JSON.parse(json)
    end

    # Hide contents of instance variables from inspection
    alias_method :inspect, :to_s

    private

    def encryption_box
      RbNaCl::SimpleBox.from_secret_key(@key)
    end
  end
end
