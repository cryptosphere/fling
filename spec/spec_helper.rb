require "coveralls"
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "fling"

RSpec.configure(&:disable_monkey_patching!)

def fixture(name)
  File.read File.expand_path("../fixtures/#{name}", __FILE__)
end
