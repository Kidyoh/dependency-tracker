# Rust

## Commands

| Task | Command |
|---|---|
| Install | `cargo fetch` |
| Outdated | `cargo outdated --root-deps-only` if `cargo-outdated` is installed; otherwise `cargo update --dry-run --verbose` for in-range updates and `cargo search <crate> --limit 1` or `cargo info <crate>` for the latest version |
| Upgrade within the range | `cargo update -p <crate> --precise <version>` |
| Upgrade past the range | `cargo add <crate>@<version>` (keeps existing features), or edit the version in `Cargo.toml`, then `cargo update -p <crate>` |
| Why required | `cargo tree -i <crate>` |

Do not install `cargo-outdated` or `cargo-edit` just for the run if they are missing; the built-in commands are enough.

In a workspace, check `[workspace.dependencies]` in the root `Cargo.toml` first. A dependency declared there is changed there, once, and members inherit it.

## What counts as major

Cargo treats the leftmost non-zero number as the breaking one: `0.3` to `0.4` is a major change, and so is `0.0.3` to `0.0.4`. Plan those as majors and read the changelog.

## Finding the changelog

```
curl -s https://crates.io/api/v1/crates/<crate> | jq '.crate.repository, .crate.documentation'
```

Send a `User-Agent` header; crates.io rejects requests without one. Most crates keep a `CHANGELOG.md` in the repository; in a multi-crate repository it sits in the crate's own subdirectory. `https://docs.rs/<crate>/<version>` shows the API of an exact version, which helps when a signature changed.

## Checks

```
cargo check --workspace --all-targets --all-features
cargo test --workspace --all-features
cargo clippy --workspace --all-targets -- -D warnings
```

Match the feature flags and clippy settings CI uses. `cargo check` is the fast loop while patching; run the tests before committing.

## Things that go wrong

- **MSRV.** Compare the new version's `rust-version` with the project's `rust-version` and `rust-toolchain.toml`. A crate that needs a newer compiler than the project pins is held back.
- **Duplicate versions.** After a major upgrade, `cargo tree -d` may show two versions of the crate, one pulled in by another dependency. Types from the two do not unify, which shows up as confusing "expected `X`, found `X`" errors. Upgrade the other dependency in the same unit, or revert.
- **Ecosystem families** that must move together: `tokio` with `tokio-util`/`tokio-stream`, `hyper` with `http`/`http-body`/`tower`/`axum`/`reqwest`/`tonic`, `serde` with `serde_derive`, `prost` with `tonic`, `opentelemetry*`, `rand` with `rand_core`.
- **Features.** Majors rename and remove features, and change the default set. A missing-item error right after an upgrade is often a feature that is now off by default.
- **`[patch]` and git dependencies.** Deliberate. Leave them.
- **`Cargo.lock` not committed** (libraries). The manifest range is then all that is recorded: widen it only when the upgrade crosses it.
