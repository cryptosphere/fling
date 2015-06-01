require "spec_helper"

RSpec.describe Fling::Box do
  let(:example_password)    { "artifical accept common any later" }
  let(:example_salt)        { "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" }
  let(:example_key)         { "dzneyh62qzzmsuvglnmmliupc3cwmdptlyz63saxp6ktl5sojzca" }
  let(:example_fingerprint) { "3rqs343l5icb4fbx4na3fgjwqij7rntba3dprkppjst7r7enxurq" }
  let(:example_message)     { Hash.new(foo: "x", bar: "y", baz: "z") }

  let(:example_box) { described_class.new(example_password, example_salt) }

  it "derives keys" do
    expect(Fling::Encoding.encode(example_box.key)).to eq example_key
    expect(example_box.fingerprint).to eq example_fingerprint
  end

  it "encrypts and decrypts hashes" do
    ciphertext = example_box.encrypt(example_message)
    expect(example_box.decrypt(ciphertext)).to eq example_message
  end
end
