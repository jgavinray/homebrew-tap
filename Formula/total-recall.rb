class TotalRecall < Formula
  desc "Markdown side-band memory enforced over the buckets it owns (MCP)"
  homepage "https://github.com/jgavinray/total-recall"
  url "https://github.com/jgavinray/total-recall/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d8a9c632078eb77bf13cf792de878c72295d95c99b14e28202813f2ae666069b"
  license "GPL-2.0-only"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      total-recall is a stdio MCP server; an MCP client spawns it, so there
      is no service to start.

      Register it in your harnesses and provision the memory root with the
      companion helper:

        total-recall-mcp install --root ~/exomemory

      That writes the omp, Pi, Claude Code, and Codex configs, seeds
      signoff.md when absent, and backs up any file it rewrites. Use
      --dry-run to inspect first, or --harness omp to select one.

      The first call in every session is read_signoff. omp exposes it as
      mcp__total_recall_read_signoff; other harnesses typically as
      mcp__total_recall__read_signoff.

      If EXOMEMORY_DIR is set, the helper refuses a --root that disagrees
      with it unless --force is given (the omp guard and the server must
      share one root).

      Verify the binary and root without starting the server:

        total-recall --root ~/exomemory --self-check
    EOS
  end

  test do
    root = testpath/"memory"
    json = shell_output("#{bin}/total-recall --root #{root} --self-check")
    assert_match '"root"', json
    assert_match '"tz"', json
    assert_match '"session"', json

    omp = testpath/"omp.json"
    system bin/"total-recall-mcp", "install", "--root", root,
           "--binary", bin/"total-recall",
           "--omp-config", omp,
           "--harness", "omp"
    assert_path_exists omp
    assert_match '"total-recall"', omp.read
    assert_path_exists root/"signoff.md"
  end
end
