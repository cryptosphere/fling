require "spec_helper"

RSpec.describe Fling::Config do
  let(:introducer)  { "pb://#{'x' * 32}@127.0.0.1:34567/#{'x' * 32}" }
  let(:convergence) { "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" }
  let(:salt)        { "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" }
  let(:dropcap)     { "URI:DIR2:#{'x' * 26}:#{'x' * 52}" }

  it "parses JSON" do
    config = described_class.from_json fixture("fling.json")

    expect(config.introducer).to eq introducer
    expect(config.convergence).to eq convergence
    expect(config.salt).to eq salt
    expect(config.dropcap).to eq dropcap
  end

  it "raises ArgumentError if a required key is missing" do
    expect { described_class.new("bogus" => "true") }.to raise_error(ArgumentError)
  end

  context "ConfigError" do
    let(:config_json) { JSON.parse(fixture("fling.json")) }
    it "raises for malformed introducer URL" do
      expect do
        described_class.new(config_json.merge("introducer" => "pbandj"))
      end.to raise_error(Fling::ConfigError)
    end

    it "raises for malformed dropcap URI" do
      expect do
        described_class.new(config_json.merge("dropcap" => "URI:DIR1"))
      end.to raise_error(Fling::ConfigError)
    end

    it "raises for malformed convergence secret" do
      expect do
        described_class.new(config_json.merge("convergence" => "_not_valid_base32_"))
      end.to raise_error(Fling::ConfigError)
    end

    it "raises for malformed salt" do
      expect do
        described_class.new(config_json.merge("salt" => "nacl"))
      end.to raise_error(Fling::ConfigError)
    end
  end
end
