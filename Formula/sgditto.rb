class Sgditto < Formula
  desc "Suppress repeated prefixes in consecutive lines"
  homepage "https://github.com/sghaf/sgditto"
  url "https://github.com/sghaf/sgditto/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "" # Update after release
  license "MIT"

  def install
    bin.install "bin/sgditto"
  end

  test do
    input = "/usr/local/bin/bash\n/usr/local/bin/dash\n"
    expected = "/usr/local/bin/bash\n               dash\n"
    assert_equal expected, pipe_output(bin/"sgditto", input)
  end
end
