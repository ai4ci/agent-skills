---
name: pi-package-npm-staging
description: Set up or debug Pi extension npm staging for single packages and workspace monorepos: `pi-package` discovery, root collection `pi.extensions`, workspace manifests and package contents, GitHub Actions `npm stage publish`, NPM_STAGE_TOKEN auth, and staged-version approval.
---

# Stage Pi extension packages to npm

Use this for one Pi extension package or a workspace monorepo publishing an aggregate Pi package and/or independently installable workspace packages. Decide which install surfaces are intended first; Pi does not infer a collection's resources by recursively reading workspace manifests.

## Monorepo layout

The reference `diegopetrucci/pi-extensions` uses a root collection package plus one workspace package per extension:

```text
repo/
  package.json             # collection metadata, workspaces, explicit Pi resources
  extensions/
    <extension>/
      package.json         # standalone npm/Pi package metadata
      index.ts             # extension entrypoint
      README.md
      test/
```

Its root manifest declares `workspaces: ["extensions/*"]`, includes the extension tree in the root package's `files` allowlist, and explicitly lists every collection entrypoint in `pi.extensions`. Individual workspace manifests have their own package name, `pi.extensions`, `files`, peer/runtime dependencies, README, and `repository.directory`. An extension can be a workspace and still be intentionally excluded from the aggregate collection; keep the root resource list explicit.

`packages/*` is equally valid when it matches the repository's existing conventions; the directory name is not what Pi reads.

Decide the npm names, the workspace directory, and the copyright holder **before** editing anything: the package names thread through the root `pi.extensions` list, every child manifest, both READMEs, the install instructions, and the release workflows, so changing them later is a repo-wide rename.

A collection package publishes resources it does not build. If the root lists TypeScript sources (Pi loads `.ts` through jiti), its `files` allowlist must carry those sources plus any vendored runtime assets, while each child typically publishes its built `dist` instead. Include a `LICENSE` and `README.md` in every package's allowlist, and drop `"private": true` from a root that is meant to publish.

The important distinction is between **workspace management** (dependencies and scripts) and **Pi resource registration** (explicit `pi.extensions`/`pi.skills` paths). For a collection install, the root manifest must list its resources and its package must contain them. Root dependencies must cover runtime dependencies needed by the aggregate install; each child must also declare the dependencies it needs when installed on its own. Pi host libraries belong in peer dependencies at the package surfaces that import them.

## Single-package procedure

1. Inspect `package.json`, the extension entrypoint, README, npm config, and existing GitHub Actions workflow before changing anything.
2. Make the package discoverable and loadable by Pi:
   - Include `"pi-package"` in `keywords` (this makes the npm package eligible for Pi's package gallery).
   - Declare actual resource paths under `pi`, for example `"pi": { "extensions": ["./src/extension.ts"] }`. The keyword alone does not configure what Pi loads.
   - Declare Pi-provided runtime libraries such as `@earendil-works/pi-coding-agent`, `@earendil-works/pi-tui`, and `typebox` as `peerDependencies`, not bundled `dependencies`.
   - Update README installation instructions to use `pi install npm:<package-name>`.
3. Set the published package deliberately:
   - For a public scoped npm package, set `publishConfig.access` to `public`.
   - Use a `files` allowlist for the README, license, and runtime extension/resource files. Keep tests, local agent instructions, and credential config such as `.npmrc` out of the tarball.
4. Check the package before staging:
   - Verify every path in `pi` exists and package JSON parses.
   - Run the project's relevant tests/build checks if present.
   - Run `npm pack --dry-run --json` and confirm only intended files are included; do not rely on `.gitignore` as the package manifest.
5. Configure a GitHub Actions workflow under `.github/workflows/` that runs on a published GitHub Release. Grant only `contents: read`, configure Node 22 or later, set the npm registry with `actions/setup-node`, install npm CLI 11.15.0 or later, and run `npm stage publish` with `NODE_AUTH_TOKEN: ${{ secrets.NPM_STAGE_TOKEN }}` on that step. `npm stage publish` is for staging-only tokens; do not substitute `npm publish`.
6. In GitHub, store the raw npm granular token with stage-only write access as the `NPM_STAGE_TOKEN` repository/org secret. Never print it in logs or commit it. The secret value must not include quotes, a `Bearer ` prefix, or surrounding whitespace/newlines.
7. Bump `package.json`'s version to a version not already staged or published, push the commit/tag, then publish the GitHub Release for that commit. Check the Actions run; a successful `npm stage publish` stages the version but does not make it public.
8. Review the staged package in npm and approve it with an authorized maintainer's 2FA. Use npm's stage list/view/approve commands or the npm UI. A staged version occupies that package version; approve or reject it rather than attempting to stage the same version again.

## Monorepo procedure

1. Keep the root collection manifest and workspace package manifests separate. Give the root its own package name/version and `pi-package` keyword if it is intended for the Pi gallery; declare the workspace glob and a `files` allowlist that includes every resource needed by the collection.
2. List every aggregate extension/skill entrypoint explicitly in the root `pi` manifest. Workspace membership alone does not make Pi load it. Keep the root README's collection list and install command in sync; call out standalone-only packages.
3. Give each independently installable workspace its own package name/version, `pi` entrypoints, `files` allowlist, runtime dependencies, Pi peer dependencies, README, and `repository.directory`. Build any `dist` files before packing if the manifest points there; do not rely on ignored/untracked build output.
4. Check the root collection and each independently published workspace separately. Run `npm pack --dry-run --json` from each package directory and inspect that package's actual tarball contents. Staging the root does not stage or publish every workspace automatically; stage/release each intended package/version deliberately.
5. Run monorepo-wide validation from the root, and test the aggregate and standalone install paths from clean package installs. For Bun catalogs, use/configure Bun consistently; Pi's package installer uses its configured `npmCommand` (npm by default), so do not assume npm can resolve Bun-specific workspace protocols.
6. In a Bun workspace, pack with `bun pm pack` and stage the resulting tarball with `npm stage publish <tarball>`. Bun rewrites `catalog:`/`workspace:` ranges into real versions while packing; `npm pack` would publish those protocol strings verbatim. `bun pm pack --quiet` still prints a leading blank line, so take the last line of its output as the tarball path.
7. Put the pack-and-stage loop in one script the workflows call (`scripts/npm-stage.sh <dir>...`, with a `--dry-run` switch through an env var), then add two thin workflows over it: a `workflow_dispatch` one that stages a single chosen package directory, and one on `release: [published]` that stages the collection and every package. Share a `concurrency` group so they cannot stage simultaneously.
8. Rehearse with `npm stage publish --dry-run <tarball>` locally. It needs no npm login, prints the real tarball contents, file count and resolved access, and is the cheapest check that every manifest is publishable.
9. After renaming or re-scoping workspace packages, refresh and commit the lockfile. CI installs with `--frozen-lockfile`, and a stale lockfile fails the job before anything is packed.

## Troubleshooting

- If the log reaches tarball details and then reports `is not a legal HTTP header value`, suspect a malformed token value—especially a trailing newline/control character or copied quotes. The token is masked in Actions logs; replace the secret with a fresh/raw token rather than printing it for debugging. When the error text appears on the line after the masked token, that strongly points to an embedded newline.
- If authentication succeeds but staging is forbidden, verify the token is a granular **Read and write (stage only)** token with access to this package, and that the npm account has package write permission.
- If the staged version already exists, choose a new version or approve/reject the existing staged entry; a failed Actions run should be checked to determine whether npm actually accepted the stage request.
- If no workflow runs, confirm the event is a published GitHub Release (not merely a branch push or tag push) and that the release commit contains the workflow.
- If `npm stage publish` reports the tarball `seems to be corrupted` and then `ENOENT` on a path that visibly concatenates the working directory and the tarball path, the path variable captured extra output (a leading blank line from `bun pm pack --quiet`). Take the last non-empty line.
- If `npm install`/`npm ci` fails with an internal Arborist error such as `Cannot read properties of null (reading 'matches')` in a Bun-managed workspace, do not debug npm: the tree was installed by Bun. Use Bun for install/build and npm only for the staging command.
- Tests inside the published tree are excluded with a negated `files` entry, for example `"!packages/*/src/*.test.ts"`; `files` has no other exclusion mechanism, and `.gitignore` does not apply.
- An agent sandbox often makes `.github/` read-only. Write the workflow files to a staging path with a header note telling the user where to move them rather than attempting to work around the restriction.

## Verification

- Pi package metadata has both the `pi-package` keyword and correct `pi` resource paths.
- For a monorepo, validate the root collection manifest and every independently installable workspace; the root resource list and root tarball include only intended aggregate resources.
- `npm pack --dry-run --json` (or `bun pm pack` plus `npm stage publish --dry-run`) contains the extension, README, license, and only other intentionally published files; it contains no token, test, or local-only files.
- Every path listed under `pi` resolves in the packed tarball, not only in the working tree.
- The GitHub Actions run succeeds at `npm stage publish`, and npm shows the expected package name/version as staged.
- A maintainer can inspect and approve the stage with 2FA; staging and public release are treated as separate steps.
