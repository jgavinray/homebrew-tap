# Jgavinray Tap

## How do I install these formulae?

`brew install jgavinray/tap/<formula>`

Or `brew tap jgavinray/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "jgavinray/tap"
brew "<formula>"
```

## Formulae

| Formula | What it provides |
| --- | --- |
| `fleet-control` | Probes local model engines and serves the fleet registry over MCP |
| `ghostwriter` | Documentation drafting over stdio MCP, backed by a local writing model |
| `total-recall` | Markdown side-band memory over stdio MCP |

### fleet-control

[fleet-control](https://github.com/jgavinray/fleet-control) probes every engine
in a `fleet.toml` registry and reports feature drift. The formula builds the
cargo workspace from source and installs three binaries:

| Binary | What it does |
| --- | --- |
| `fleet-check` | Probes every engine in the registry and reports results |
| `fleet-mcp` | MCP stdio server that exposes the registry check as a tool |
| `fleet-stopgap` | launchd watcher for fleet checks (macOS only) |

```sh
brew install jgavinray/tap/fleet-control
```

The formula pins the `v0.1.0` tag of the upstream repository. `brew install
--HEAD` builds the tip of `main` instead, which is useful before a tag exists
and for testing unreleased changes.

There are no bottles yet, so Homebrew builds the Rust workspace on your
machine. The formula pulls in `rust` as a build-only dependency; the installed
binaries are self-contained and have no runtime dependencies.

After installing, `fleet-check` needs a registry. It reads `$FLEET_REGISTRY`
first, then `~/.config/fleet-control/fleet.toml`, then a `fleet.toml` found by
walking up from the binary's symlink target — so a clone of the repository also
works. The worker agent definition and the stopgap launchd job live in the
repository rather than in the formula:

```sh
git clone https://github.com/jgavinray/fleet-control.git
cd fleet-control
agents/install.sh        # symlinks the worker agent into ~/.claude and ~/.omp
fleet-stopgap install    # writes and loads the launchd plist (macOS only)
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
