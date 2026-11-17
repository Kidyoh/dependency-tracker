# Go

## Commands

| Task | Command |
|---|---|
| Install | `go mod download` |
| Outdated, direct only | `go list -m -u -f '{{if and .Update (not .Indirect)}}{{.Path}} {{.Version}} {{.Update.Version}}{{end}}' all` |
| Upgrade one | `go get <module>@<version>` then `go mod tidy` |
| Why required | `go mod why -m <module>` |

In a workspace (`go.work`), run the commands in each module directory.

## Major versions

From v2 on, the major version is part of the import path (`example.com/mod/v2`). `go list -m -u` never reports a new major: it only looks within the current path. To find one, check the module's repository tags or `https://pkg.go.dev/<module>?tab=versions`.

A major upgrade means:

1. `go get <module>/v<N>@latest`
2. Rewrite every import of the old path to the new one, across all packages.
3. `go mod tidy` to drop the old major.

Modules tagged `+incompatible` did not adopt module-aware paths; their majors upgrade like any other version.

## Finding the changelog

The module path is usually the repository. For vanity paths (`gopkg.in/...`, `go.uber.org/...`, `google.golang.org/...`), the repository link is on `https://pkg.go.dev/<module>`. Go projects often have no changelog file: use GitHub releases, then the diff between tags.

## Checks

```
go build ./...
go vet ./...
go test ./...
```

Add `-race` to the test run if CI does. Use the linter CI uses (commonly `golangci-lint run`).

## Things that go wrong

- **`go` directive.** `go get` may raise the `go` line or add a `toolchain` line in `go.mod` when the new version needs a newer Go. If that exceeds the Go version in CI, pick an older version of the module instead and report it.
- **`replace` and `exclude`.** These are deliberate. Leave a replaced module alone.
- **Indirect bumps.** Upgrading one module can raise many `// indirect` lines. That is expected; review the `go.mod` diff for any unrelated direct dependency that moved, since minimal version selection can raise one.
- **Vendoring.** If `vendor/` exists, run `go mod vendor` after `go mod tidy` and commit the result.
- **Generated code.** A protobuf, gRPC or mock library upgrade usually needs the generators rerun (`go generate ./...` or the project's make target) with a matching generator version.
- **`golang.org/x/*`.** These have no semver guarantees worth trusting at v0; read the diff for the packages the project imports.
