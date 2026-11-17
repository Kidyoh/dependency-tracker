# Other ecosystems

When the project uses something without its own reference file, work out the same five facts before touching anything:

1. **Manifest and lockfile.** Which file declares dependencies, and which records resolved versions.
2. **Outdated command.** How the package manager lists newer versions.
3. **Upgrade command.** How to move one dependency so the lockfile follows.
4. **Checks.** What CI runs.
5. **Repository lookup.** How to get from a package name to its source repository and changelog.

Then follow the main procedure unchanged.

## Starting points

| Ecosystem | Manifest / lock | Outdated | Upgrade one | Checks |
|---|---|---|---|---|
| Ruby | `Gemfile` / `Gemfile.lock` | `bundle outdated --only-explicit` | `bundle update <gem> --conservative` (edit `Gemfile` if the constraint blocks it) | `bundle exec rspec`, `bundle exec rake test` |
| PHP | `composer.json` / `composer.lock` | `composer outdated --direct` | `composer require <pkg>:^<ver> --with-dependencies` | `composer test`, `vendor/bin/phpunit` |
| Java, Maven | `pom.xml` | `mvn versions:display-dependency-updates` | edit the version or its property in `pom.xml` | `mvn verify` |
| Java/Kotlin, Gradle | `build.gradle(.kts)`, `gradle/libs.versions.toml` | `./gradlew dependencyUpdates` (if the versions plugin is applied) | edit the version, preferably in the version catalog | `./gradlew check` |
| .NET | `*.csproj`, `Directory.Packages.props` | `dotnet list package --outdated` | `dotnet add package <pkg> --version <ver>` | `dotnet build`, `dotnet test` |
| Elixir | `mix.exs` / `mix.lock` | `mix hex.outdated` | `mix deps.update <dep>` (edit `mix.exs` if the constraint blocks it) | `mix test` |
| Dart, Flutter | `pubspec.yaml` / `pubspec.lock` | `dart pub outdated` | `dart pub upgrade <pkg> --major-versions` | `dart test`, `flutter test` |
| Swift | `Package.swift` / `Package.resolved` | `swift package show-dependencies`, compare with repository tags | edit the requirement, `swift package update <pkg>` | `swift build`, `swift test` |
| GitHub Actions | `.github/workflows/*.yml` | compare each `uses:` ref with the action's releases | edit the ref; keep SHA pins as SHA pins with the version in a comment | the workflow itself; lint with `actionlint` if present |
| Docker | `Dockerfile`, compose files | compare `FROM` tags with the registry | edit the tag; keep digest pins as digests | build the image |

Check `<tool> --help` before trusting a command from this table: flags differ across versions.

## Where versions are shared

Many projects declare a version once and reference it in several places: Maven properties, Gradle version catalogs, `Directory.Packages.props`, a `.tool-versions` file. Change the single source. If the same version also appears in CI config, a Dockerfile or docs, update those in the same commit.

## When there is no tooling

If the ecosystem has no outdated command, read the manifest, look each dependency up in its registry, and compare versions yourself. Say in the report that the list was built by hand and may be incomplete.
