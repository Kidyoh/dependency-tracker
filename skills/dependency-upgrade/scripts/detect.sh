#!/usr/bin/env bash
# Find dependency manifests under a project root.
# Prints one tab-separated line per manifest: ecosystem, directory, package manager, manifest file.
# Usage: detect.sh [project-root]

set -euo pipefail

root="${1:-.}"
cd "$root"

has() { [ -e "$1/$2" ]; }

js_manager() {
  local d="$1" pm=""
  if [ -f "$d/package.json" ]; then
    pm=$(sed -n 's/.*"packageManager"[[:space:]]*:[[:space:]]*"\([a-z]*\)@.*/\1/p' "$d/package.json" | head -n 1)
  fi
  if [ -n "$pm" ]; then echo "$pm"; return; fi
  # A workspace member has no lockfile of its own, so look upward.
  local cur="$d"
  while :; do
    if has "$cur" pnpm-lock.yaml; then echo pnpm; return; fi
    if has "$cur" yarn.lock; then echo yarn; return; fi
    if has "$cur" bun.lock || has "$cur" bun.lockb; then echo bun; return; fi
    if has "$cur" package-lock.json || has "$cur" npm-shrinkwrap.json; then echo npm; return; fi
    [ "$cur" = "." ] && break
    cur=$(dirname "$cur")
  done
  echo npm
}

py_manager() {
  local d="$1"
  if has "$d" uv.lock; then echo uv; return; fi
  if has "$d" poetry.lock; then echo poetry; return; fi
  if has "$d" pdm.lock; then echo pdm; return; fi
  if has "$d" Pipfile; then echo pipenv; return; fi
  if [ -f "$d/pyproject.toml" ]; then
    if grep -q '^\[tool\.uv' "$d/pyproject.toml"; then echo uv; return; fi
    if grep -q '^\[tool\.poetry' "$d/pyproject.toml"; then echo poetry; return; fi
    if grep -q '^\[tool\.pdm' "$d/pyproject.toml"; then echo pdm; return; fi
  fi
  if ls "$d"/requirements*.in >/dev/null 2>&1; then echo pip-tools; return; fi
  echo pip
}

emit() { printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4"; }

found=0
seen_py=""

while IFS= read -r path; do
  dir=$(dirname "$path")
  file=$(basename "$path")
  case "$file" in
    package.json)
      emit javascript "$dir" "$(js_manager "$dir")" "$file" ;;
    pyproject.toml|Pipfile|setup.py|requirements*.txt)
      # One line per Python directory, naming the most authoritative manifest.
      case "$seen_py" in *"|$dir|"*) continue ;; esac
      seen_py="$seen_py|$dir|"
      manifest="$file"
      for m in pyproject.toml Pipfile setup.py; do
        if has "$dir" "$m"; then manifest="$m"; break; fi
      done
      emit python "$dir" "$(py_manager "$dir")" "$manifest" ;;
    go.mod)
      emit go "$dir" go "$file" ;;
    Cargo.toml)
      emit rust "$dir" cargo "$file" ;;
    Gemfile)
      emit ruby "$dir" bundler "$file" ;;
    composer.json)
      emit php "$dir" composer "$file" ;;
    pom.xml)
      emit java "$dir" maven "$file" ;;
    build.gradle|build.gradle.kts)
      emit java "$dir" gradle "$file" ;;
    *.csproj|*.fsproj)
      emit dotnet "$dir" dotnet "$file" ;;
    mix.exs)
      emit elixir "$dir" mix "$file" ;;
    pubspec.yaml)
      emit dart "$dir" pub "$file" ;;
    Package.swift)
      emit swift "$dir" swiftpm "$file" ;;
  esac
  found=1
done < <(
  find . \
    \( -name node_modules -o -name .git -o -name vendor -o -name target \
       -o -name .venv -o -name venv -o -name dist -o -name build \
       -o -name .tox -o -name __pycache__ -o -name .next \) -prune -o \
    -type f \( -name package.json -o -name pyproject.toml -o -name Pipfile \
       -o -name setup.py -o -name 'requirements*.txt' -o -name go.mod \
       -o -name Cargo.toml -o -name Gemfile -o -name composer.json \
       -o -name pom.xml -o -name build.gradle -o -name build.gradle.kts \
       -o -name '*.csproj' -o -name '*.fsproj' -o -name mix.exs \
       -o -name pubspec.yaml -o -name Package.swift \) -print | sort
)

if [ "$found" -eq 0 ]; then
  echo "No dependency manifests found under $(pwd)" >&2
  exit 1
fi
