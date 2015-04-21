module Fling
  module Setup
    def self.run
      os = RbConfig::CONFIG["host_os"]

      case os
      when /^darwin/
        require 'fling/setup/osx'
        Fling::Setup::OSX.run
      else fail NotImplementedError, "unsupported OS: #{os}"
      end
    end
  end
end
