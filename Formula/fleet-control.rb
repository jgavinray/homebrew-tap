class FleetControl < Formula
  desc "Probe local model engines and expose the fleet registry over MCP"
  homepage "https://github.com/jgavinray/fleet-control"
  url "https://github.com/jgavinray/fleet-control.git", tag: "v0.1.0"
  license "GPL-2.0-only"
  head "https://github.com/jgavinray/fleet-control.git", branch: "main"

  depends_on "rust" => :build

  def install
    cargo_root = buildpath/"cargo-install"

    system "cargo", "install", *std_cargo_args(root: cargo_root, path: "crates/fleet-check-rs"),
           "--bin", "fleet-check-rs"
    system "cargo", "install", *std_cargo_args(root: cargo_root, path: "crates/fleet-mcp"),
           "--bin", "fleet-mcp"
    system "cargo", "install", *std_cargo_args(root: cargo_root, path: "crates/fleet-stopgap"),
           "--bin", "fleet-stopgap"

    bin.install cargo_root/"bin/fleet-check-rs" => "fleet-check"
    bin.install cargo_root/"bin/fleet-mcp"
    bin.install cargo_root/"bin/fleet-stopgap"
  end

  def caveats
    <<~EOS
      fleet-check resolves the engine registry in this order: $FLEET_REGISTRY,
      then ~/.config/fleet-control/fleet.toml, then a fleet.toml found by walking
      up from the binary's symlink target. On a machine without the config file,
      a fleet-control checkout with fleet.toml at its root is enough.

      The omp and Claude Code worker agent definition ships with the repository,
      not with this formula:
        git clone https://github.com/jgavinray/fleet-control.git
        cd fleet-control && agents/install.sh

      The stopgap watcher runs under launchd and installs its own plist:
        fleet-stopgap install
    EOS
  end

  test do
    assert_predicate bin/"fleet-check", :executable?
    assert_predicate bin/"fleet-mcp", :executable?
    assert_predicate bin/"fleet-stopgap", :executable?

    assert_match "usage: fleet-check", shell_output("#{bin}/fleet-check --help")
    shell_output("#{bin}/fleet-mcp --help < /dev/null")
  end
end
