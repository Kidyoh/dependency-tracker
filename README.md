# dep-upgrade

A Claude plugin that upgrades your dependencies. It reads the changelog and breaking changes for each outdated dependency, upgrades it, patches the code the change breaks, and runs your tests, one dependency at a time.

- Each dependency gets its own commit, so a bad upgrade is easy to find and undo.
- A dependency that still fails after patching is reverted and listed in the report. The run carries on with the rest.
- Supports JavaScript/TypeScript (npm, pnpm, yarn, bun), Python (uv, poetry, pip), Go and Rust, with a generic fallback for Ruby, PHP, Java, .NET, Elixir, Dart, Swift, GitHub Actions and Docker.

## Install in Claude Code

```
/plugin marketplace add kidyoh/dependency-tracker
```

```
/plugin install dep-upgrade@dependency-tracker
```

## Use

```
/dep-upgrade:upgrade-deps
```

| Argument | Effect |
|---|---|
| `react zod` | Upgrade only the named packages |
| `--dry-run` | Show the plan and the breaking changes found, change nothing |
| `--no-major` | Skip upgrades that cross a major version |
| `--only js` | Limit to one ecosystem: `js`, `python`, `go`, `rust` |

You can also just ask: "upgrade my dependencies" or "what would upgrading to Next 16 break?". Claude hands the work to the `dependency-upgrader` agent.

Start from a clean git working tree. The agent stops if there are uncommitted changes, because it uses git to revert failed upgrades. It commits locally and never pushes.

## Use on claude.ai

The skill works on its own, without the plugin. Zip the `skills/dependency-upgrade` folder and upload the zip under Settings, Capabilities, Skills.

## What is in here

| Path | Purpose |
|---|---|
| `.claude-plugin/` | Plugin and marketplace manifests |
| `commands/upgrade-deps.md` | The slash command |
| `agents/dependency-upgrader.md` | The subagent that does the run |
| `skills/dependency-upgrade/SKILL.md` | The procedure |
| `skills/dependency-upgrade/references/` | Commands and pitfalls for each ecosystem |

## Data handling

The plugin has no server of its own and stores nothing outside your project. It does not read or collect personal data.

To find versions and changelogs, it makes read-only requests to public services, sending only package names and version numbers:

- Package registries: npmjs.com, pypi.org, crates.io, proxy.golang.org and pkg.go.dev, plus the registry of any other ecosystem your project uses.
- Source hosts: github.com and api.github.com (or wherever a package's repository lives) for release notes, changelog files and migration guides.
- Package documentation sites, such as docs.rs, when a changelog links to them.

Your package manager also contacts its configured registry when it installs an upgraded version, as it would if you ran the upgrade by hand. Your source code is not sent to any of these services.

## What it will not do

- Skip, delete or weaken a test to get a pass.
- Move a version you pinned on purpose (`overrides`, `resolutions`, `replace`, `[patch]`, or a commented pin).
- Push, open a pull request or publish.
