class Xtop < Formula
  desc "Htop-style terminal monitor for Intel GPUs"
  homepage "https://github.com/jgavinray/xtop"
  url "https://github.com/jgavinray/xtop/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "cd6b3a6b90e076a48947f11daf4e5f93b19fa6d36e2bd35c05b9b5f91c119a3d"
  license "GPL-2.0-only"
  head "https://github.com/jgavinray/xtop.git", branch: "main"

  depends_on "rust" => :build
  # Reads Linux sysfs, /proc fdinfo and DRM ioctls; there is nothing to
  # monitor on macOS.
  depends_on :linux

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      xtop reads the GPU directly through sysfs, /proc and /dev/dri. Device-wide
      VRAM needs read/write access to the render node (membership of the
      `render` group on most distributions). Without root, the process table
      lists only your own GPU clients.
    EOS
  end

  test do
    # Both flags exit before GPU discovery, so they work on hosts without one.
    assert_match "xtop #{version}", shell_output("#{bin}/xtop --version")
    assert_match "USAGE", shell_output("#{bin}/xtop --help")
  end
end
