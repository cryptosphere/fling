require "spec_helper"

RSpec.describe Fling::Encoding do
  let(:source) { "XXXXXXXXXXXXXXXX" }
  let(:base32) { "lbmfqwcylbmfqwcylbmfqwcyla" }

  it "encodes to base32" do
    expect(subject.encode(source)).to eq base32
  end

  it "decodes from base32" do
    expect(subject.decode(base32)).to eq source
  end
end
