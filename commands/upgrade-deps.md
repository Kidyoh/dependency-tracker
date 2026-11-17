---
description: Upgrade outdated dependencies one at a time, reading changelogs, patching code and running tests
argument-hint: "[package ...] [--dry-run] [--no-major] [--only <ecosystem>]"
---

Run a dependency upgrade on this project.

Arguments: $ARGUMENTS

Launch the `dependency-upgrader` agent and pass it the arguments above unchanged. If that agent is not available, load the `dependency-upgrade` skill and follow it yourself.

How to read the arguments:

- Package names: upgrade only those packages. With none, upgrade everything that is outdated.
- `--dry-run`: produce the upgrade plan with the breaking changes found in the changelogs, and change nothing.
- `--no-major`: skip upgrades that cross a major version.
- `--only <ecosystem>`: limit the run to `js`, `python`, `go` or `rust`.

When the agent finishes, show its final report to the user in full.
