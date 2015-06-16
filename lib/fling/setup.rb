require "colorize"
require "fileutils"

module Fling
  # Central utilities for Tahoe-LAFS setup
  module Setup
    module_function

    TAHOE_VERSION = "1.10.1"
    TAHOE_DIR     = "allmydata-tahoe-#{TAHOE_VERSION}"
    TAHOE_ZIP     = "#{TAHOE_DIR}.zip"
    TAHOE_SRC     = "https://tahoe-lafs.org/source/tahoe-lafs/tarballs/#{TAHOE_ZIP}"

    # Note something important just happened
    def ohai(msg)
      STDOUT.puts "#{'***'.blue} #{msg.light_white}"
    end

    def run
      zip = "/tmp/#{TAHOE_ZIP}"
      dir = File.join(Dir.home, TAHOE_DIR)

      ohai "Downloading #{TAHOE_ZIP}"
      system "curl -o #{zip} #{TAHOE_SRC}"

      ohai "Extracting #{TAHOE_ZIP} into #{dir}"
      system "cd #{Dir.home} && unzip -q #{zip}"

      ohai "Configuring Tahoe-LAFS"
      system "cd #{dir} && python setup.py build"

      ohai "Tahoe-LAFS is ready to roll."
    end
  end
end
