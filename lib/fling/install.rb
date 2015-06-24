require "colorize"
require "fileutils"

module Fling
  # Central utilities for Tahoe-LAFS setup
  module Install
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

      ohai "Linking 'tahoe' executable to ~/bin/tahoe..."

      user_bin  = File.expand_path("~/bin")
      tahoe_bin = File.expand_path("~/#{TAHOE_DIR}/bin")

      FileUtils.mkdir_p(user_bin)
      FileUtils.ln_sf(File.join(tahoe_bin, "tahoe"), File.join(user_bin, "tahoe"))

      ohai "Tahoe-LAFS is ready to roll."
    end
  end
end
