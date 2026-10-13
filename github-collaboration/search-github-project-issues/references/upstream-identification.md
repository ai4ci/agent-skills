# Identifying and Searching Upstream Projects

When debugging a dependency or tool, the first step is finding the right
GitHub repository to search. This is not always obvious — the package you
install may be a wrapper, the real code lives elsewhere.

---

## Finding the GitHub Repo for a Package

The package you install is rarely the source of truth. Find the actual
source repo using the method below for your ecosystem.

### PyPI (Python)

```bash
# PyPI JSON API — project_urls contains the source URL
curl -s https://pypi.org/pypi/<package>/json | jq '.info.project_urls'

# Look for: Repository, Source, Homepage, GitHub
# The "Repository" URL is most likely to be the actual source

# If installed locally:
pip show <package> | grep -i home
```

**Gotcha:** Not all PyPI packages are on GitHub. Some use GitLab, Bitbucket,
or self-hosted repos. Always check `project_urls` before assuming GitHub.

### npm (JavaScript)

```bash
# The repository URL is embedded in package metadata
npm view <package> repository.url

# Also check homepage for the actual source
npm view <package> homepage
```

### Maven (Java)

```bash
# Display full dependency tree, including transitive deps
mvn dependency:tree -Dverbose

# Look for SCM (Source Control Management) URLs in the POM
# Or check Maven Central:
# https://mvnrepository.com/artifact/<groupId>/<artifactId>
# The "SCM" section lists the source repo URL
```

### RubyGems (Ruby)

```bash
# Gem metadata includes source information
gem info <gem>

# Or check RubyGems.org directly:
# https://rubygems.org/gems/<gem>
# Look for "Project URL", "Source Code", or "Bug Tracker"
```

### Cargo (Rust)

```bash
# Check the crate page on crates.io
# https://crates.io/crates/<crate-name>
# Look for "Repository" URL

# Or from installed package:
cargo metadata --format-version=1 | jq '.packages[] | select(.name=="<crate>") | .source, .repository'
```

### Go Modules

```bash
# Check proxy.golang.org for module metadata, including the repo URL
curl -s https://proxy.golang.org/<module>/@latest | jq '.Origin.URL // .Origin.Ref'

# Check go.sum for the resolved version
# The import path often IS the repo URL for Go modules hosted on GitHub:
#   github.com/owner/repo → https://github.com/owner/repo

# Show why a module is required (reverse dependency trace)
go mod why -m <module>

# List all modules in the build
# There's no standalone source-URL lookup command; check the module path
# directly — most Go module paths are already VCS URLs.
```

**Gotcha:** Go module paths are usually the VCS URL itself (e.g.
`github.com/gin-gonic/gin`). If the path doesn't match a known host,
check the module's `go.mod` for a `replace` directive or use the proxy
endpoint above.

---

## Handling Transitive Dependencies

The bug may not be in the package you directly depend on — it may be in a
transitive dependency several layers deep.

### Tracing the dependency chain

```bash
# npm — show the full tree
npm ls <package>

# Python — show what depends on this package
pip show <package>          # shows reverse dependencies
pipdeptree                  # shows the full tree (requires pipdeptree)

# Maven — show dependency tree
mvn dependency:tree -Dverbose
```

### Strategy

1. **Check the direct dependency first** — if you depend on `library-a`, search
   `library-a`'s issues before searching any transitive deps.
2. **If no match, trace the chain** — use `npm ls`, `pipdeptree`, or
   `mvn dependency:tree` to find the transitive dependency.
3. **Then search that upstream repo** — use the method above to find its
   GitHub repo, then search its issues/PRs.

**Gotcha:** A transitive dependency may appear at multiple depths in the tree.
The version actually resolved may differ from what you expected. Always verify
the resolved version before searching.

---

## Searching Upstream Repositories Effectively

Once you have the target repo, use search patterns optimized for finding
relevant issues:

### Search by package name + symptom

```bash
# Always use --state all: closed issues may have been closed
# without a fix (unconfirmed, out of scope, duplicate)
gh search issues "<package-name>" "error message or symptom" --state all --repo owner/repo

# For performance issues, include the function/method name
gh search issues owner/repo "function_name" "timeout" OR "slow" OR "hang" --state all
```

### Search by version-specific issues

```bash
# Issues introduced in a specific version
gh search issues owner/repo "regression" "v2.3.0" OR "2.3.0" --state all
gh search issues owner/repo "introduced in" "v2.3.0" --state all
```

### Search PRs for fixes

```bash
# Merged fixes (PRs are always either merged or open)
gh search prs owner/repo "fix" "error message" --state merged

# Open PRs that might not be released yet
gh search prs owner/repo "fix" "error message" --state open
```

### Search code for implementation context

```bash
# Search the actual code where the bug lives
gh search code "function_name" "error handling" --repo owner/repo --ext py
```

---

## Important: Always Include Closed Issues

Search with `--state all` (not `--state open`). A bug may have been:
- Reported and closed as "unconfirmed" (no one could reproduce it)
- Closed as "out of scope" (the maintainer doesn't want to fix it)
- Closed as a duplicate without the root cause being addressed
- Closed after a fix was merged but not yet released

These closed issues often contain the most useful information — the exact error message, reproduction steps, and maintainer commentary. An issue closed as "unconfirmed" is still valuable: it tells you the bug exists and others have seen it too.

## When No Match Found

If searching the upstream repo returns no relevant results:

1. **Try alternative search terms** — the maintainer may have described the
   issue differently (e.g., "crash" vs "segfault" vs "undefined behavior").
2. **Search closed issues** — the issue may have been fixed but not yet
   released. Search with `--state closed` and check the linked PR.
3. **Check the CHANGELOG/RELEASES** — read recent release notes to see if
   the symptom matches a documented fix.
4. **Check the discussion tab** — some projects discuss issues there before
   filing formal issues.
5. **If truly unknown, report it** — now that you've verified it's not a
   known issue, create a new issue (read the appropriate reference for
   issue-writing guidance).

---

## Quick Reference: Ecosystem Commands

| Ecosystem | Find source URL | Show dependency tree |
|---|---|---|
| PyPI | `curl https://pypi.org/pypi/X/json \| jq .info.project_urls` | `pipdeptree` |
| npm | `npm view X repository.url` | `npm ls X` |
| Maven | Check POM SCM URL / Maven Central | `mvn dependency:tree -Dverbose` |
| RubyGems | Check rubygems.org/project-url | `gem dependency X` |
| Go modules | `curl https://proxy.golang.org/<module>/@latest \| jq .Origin` | `go mod why -m <package>` |
| Cargo | Check crates.io/repository | `cargo tree` |
