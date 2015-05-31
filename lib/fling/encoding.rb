require "base32"

module Fling
  # Encoder/decoder for z-base-32 used by Tahoe-LAFS
  module Encoding
    module_function

    # Encode a string in z-base-32
    #
    # @param string [String] arbitrary string to be encoded
    # @return [String] lovely, elegant z-base-32
    def encode(string)
      Base32.encode(string).downcase.sub(/=+$/, "")
    end

    # Decode a z-base-32 string
    #
    # @param string [String] z-base-32 string to be decoded
    # @return [String] decoded string
    def decode(string)
      Base32.decode(string.upcase)
    end
  end
end
