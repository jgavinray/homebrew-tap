class Ghostwriter < Formula
  desc "Documentation drafting over stdio MCP, backed by a local writing model"
  homepage "https://github.com/jgavinray/ghostwriter"
  url "https://github.com/jgavinray/ghostwriter/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "820af265fe91573d27a61e1533683f7052f16fea9f81a0ba814358f799419b10"
  license "GPL-2.0-only"

  depends_on "rust" => :build

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    pkgshare.install "assets/config.example.toml"
    (share/"licenses/#{name}").install "LICENSE" => "COPYING"
  end

  def caveats
    <<~EOS
      ghostwriter serves MCP over stdio; an MCP client spawns it, so there
      is no service to start.

      It talks to an OpenAI-compatible writing-model server. The built-in
      default is a loopback placeholder, not a working server: point it at
      your model endpoint, e.g.

        mkdir -p ~/.config/ghostwriter
        cp #{opt_pkgshare}/config.example.toml ~/.config/ghostwriter/config.toml
        $EDITOR ~/.config/ghostwriter/config.toml

      or set base_url/model via GHOSTWRITER_BASE_URL / GHOSTWRITER_MODEL.
      Verify what resolves without starting the server:

        ghostwriter --self-check

      Your MCP client's per-server timeout must exceed the server's
      timeout_secs (900 s by default).
    EOS
  end

  test do
    config = testpath/"config.toml"
    config.write <<~TOML
      base_url = "http://127.0.0.1:9/v1"
      model = "test-model"
      temperature = 0.3
      timeout_secs = 60
      idle_timeout_secs = 10
      style = "none"
    TOML

    # --self-check resolves the configuration and exits before the stdio
    # transport exists: no stdin read, no socket.
    json = shell_output("#{bin}/ghostwriter --self-check --config #{config}")
    assert_match '"base_url":"http://127.0.0.1:9/v1"', json
    assert_match '"model":"test-model"', json

    assert_match "usage: ghostwriter", shell_output("#{bin}/ghostwriter --help")
  end
end
