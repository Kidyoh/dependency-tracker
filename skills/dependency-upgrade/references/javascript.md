# JavaScript and TypeScript

## Package manager

Pick by lockfile, and never mix managers:

| Lockfile | Manager |
|---|---|
| `pnpm-lock.yaml` | pnpm |
| `yarn.lock` | yarn (check `packageManager` in `package.json` for v1 vs berry) |
| `bun.lock`, `bun.lockb` | bun |
| `package-lock.json`, or none | npm |

A `packageManager` field in `package.json` wins over the lockfile guess. In a workspace (`workspaces` field, `pnpm-workspace.yaml`), run commands from the root and target the workspace that declares the dependency.

## Commands

| Task | npm | pnpm | yarn berry | bun |
|---|---|---|---|---|
| Install | `npm ci` | `pnpm install --frozen-lockfile` | `yarn install --immutable` | `bun install --frozen-lockfile` |
| Outdated | `npm outdated --json` | `pnpm outdated --format json` (`-r` for workspaces) | `yarn outdated` (plugin) or `yarn upgrade-interactive` | `bun outdated` |
| Upgrade one | `npm install <pkg>@<ver>` | `pnpm add <pkg>@<ver>` | `yarn up <pkg>@<ver>` | `bun add <pkg>@<ver>` |
| Why installed | `npm ls <pkg>` | `pnpm why <pkg>` | `yarn why <pkg>` | `bun pm ls` |

`npm outdated` exits with status 1 when anything is outdated. That is not an error.

Keep a dependency in the section it is already in: add `-D` (or `--dev`) for `devDependencies`. Keep the existing range style (`^`, `~`, exact).

## Finding the changelog

```
npm view <pkg> repository.url homepage
npm view <pkg> versions --json
```

The installed copy often ships its changelog: `node_modules/<pkg>/CHANGELOG.md`. After upgrading, that file covers the whole range.

## Checks

Use the scripts in `package.json`. Typical set: `build`, `typecheck` (or `tsc --noEmit` when there is a `tsconfig.json` and no script), `lint`, `test`. Run a test script with CI mode on so watchers do not hang: `CI=1 npm test`.

## Things that go wrong

- **Peer dependencies.** An `ERESOLVE` or unmet-peer warning means a plugin does not yet support the new major of its host. Upgrade the plugin in the same unit, or hold the host back. Do not use `--force` or `--legacy-peer-deps` unless the project already does.
- **`@types/*`.** Upgrade with the package it describes, to the matching major. Drop the `@types` package when the new version ships its own types.
- **ESM-only releases.** A major that drops CommonJS breaks `require()` callers. Check the project's `type` field and `module` settings before upgrading; revert if the project cannot import ESM.
- **`engines`.** Compare the new version's `engines.node` with the Node version in CI (`.nvmrc`, `.node-version`, workflow files).
- **TypeScript.** A TypeScript minor can add new errors. Treat it as a major.
- **Snapshots.** A formatter or renderer upgrade can change snapshots. Update a snapshot only after reading the diff and confirming it is formatting, not behaviour.
- **`overrides`, `resolutions`, `pnpm.overrides`, `patch-package`.** These are deliberate. A patched package needs its patch re-checked against the new version; if the patch no longer applies, revert and report.
