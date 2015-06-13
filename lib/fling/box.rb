require "json"
require "rbnacl/libsodium"

module Fling
  # Simple encryption with password-derived keys
  class Box
    attr_reader :key, :fingerprint

    SALT_SIZE = 32
    FINGERPRINT_SIZE = 32

    SCRYPT_OPSLIMIT = 2**25
    SCRYPT_MEMLIMIT = 2**30

    def self.encrypt(password, plaintext, options = {})
      salt = RbNaCl::Random.random_bytes(SALT_SIZE)
      box = new(password, salt, options)
      salt + box.encrypt(plaintext)
    end

    def self.decrypt(password, ciphertext, options = {})
      salt = ciphertext[0, SALT_SIZE]
      ciphertext = ciphertext[SALT_SIZE, ciphertext.length - SALT_SIZE]
      box = new(password, salt, options)
      box.decrypt(ciphertext)
    end

    def initialize(password, salt, options = {})
      opts = {
        scrypt_opslimit: SCRYPT_OPSLIMIT,
        scrypt_memlimit: SCRYPT_MEMLIMIT
      }.merge(options)

      @key = RbNaCl::PasswordHash.scrypt(
        password.force_encoding("BINARY"),
        salt.force_encoding("BINARY"),
        opts[:scrypt_opslimit],
        opts[:scrypt_memlimit],
        RbNaCl::SecretBox::KEYBYTES
      )

      @fingerprint = Encoding.encode(RbNaCl::Hash.blake2b(@key, digest_size: FINGERPRINT_SIZE))
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
