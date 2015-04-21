require "fling"
require "thor"

module Fling
  class CLI < Thor
    desc :setup, "Install Tahoe-LAFS"
    def setup
      require "fling/setup"
      Setup.run
    end
  end
end
