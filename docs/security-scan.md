# Security scan: VibeGuard, npm audit and Semgrep

Run on 2026-10-29 against the whole project. Recorded because the `overrides` block in
`site/package.json` is otherwise unexplained, and because the scan is weaker than its own output
makes it look.

## VibeGuard 1.1.11

A scanner orchestrator for AI-generated code. Three things about getting it running on this machine,
all of them obstacles:

- `pip install vibeguard-cli` **fails**. Every published version requires Python >= 3.11 and this
  machine has 3.9, with no Homebrew, no pyenv and no alternate Python.
- The standalone binary works. The asset is named `vibeguard-macos-amd64.tar.gz` but it is actually
  an **arm64** build, so it runs natively on this Apple Silicon machine with no Rosetta. The name is
  simply wrong. It bundles its own Python 3.11, which is why the system's 3.9 does not matter.
- Their download page advertises a **Linux** portable build that does not exist in the release at
  all. Worth not trusting that page.

It was unpacked to the session scratchpad, not installed system-wide.

### It writes into the repository without being asked

Running a scan leaves three things in the project root:

| Path | What it is |
|---|---|
| `.vibeguard/cache/scan_<timestamp>.json` | 64 KB of raw scanner output, transient |
| `.vibeguard/baselines/initial.json` | An auto-created baseline, empty here because nothing was actionable |
| `vibeguard-report-<timestamp>.html` | A 28 KB rendered report |

All three are gitignored. The baseline is the reason: it stores `repo_root` as an **absolute path**,
so committing one would put `/Users/<name>/...` into a shared repository, and it would suppress
whatever it captured from every future scan. Baselines are for deliberately tracking known legacy
findings, not an automatic side effect of looking. If a shared baseline is ever wanted, create it on
purpose and un-ignore `baselines/`.

### Result

```
Score              100   Grade  A+
Actionable score   100
Severity counts    0 critical, 0 high, 0 medium, 0 low, 0 info
Noise ratio        1.0       every finding classified as noise
Partial            true      three of five scanners could not run
Scanners that ran  trufflehog
Scanners skipped   semgrep, gitleaks, trivy, bandit
```

Forty raw findings, every one of them a false positive:

- 36 in `node_modules`: `typescript.js`, `_tsc.js`, `es-abstract`, `sucrase`, `jiti`, a compiled
  `.node` binary, a vendored `yarn.lock`.
- 4 in `site/.next/cache/webpack/`.

The rules that matched are Gitleaks' generic entropy patterns: `EtsyApiKey` (24), `Signable` (9),
`FixerIO` (4), `Polygon`, `Redis`, `MongoDB`. These match any high-entropy string, which minified
JavaScript is made of. **Nothing in our own source was flagged.** VibeGuard triaged all forty as
`ignored (generated_cache)`, which is the deduplication and triage it advertises, working.

The headline "41 leaks found" in the raw log is the number before triage. Read the score, not the raw
count.

### What it could not check

Semgrep, Trivy and Bandit were unavailable, so the scan covered almost nothing that matters for a
Next.js and TypeScript project. Secrets were checked. Code patterns and dependency CVEs were not.
Trivy and the others want Docker, which is not installed, and Semgrep and Bandit install through pip,
which is blocked by the Python version. This is why the two checks below were run directly instead.

## npm audit: one real finding

```
high      postcss  <= 8.5.22
moderate  next     9.3.4-canary.0 - 16.3.0-preview.10   (depends on postcss)
```

**Fixed.** The vulnerable copy was `postcss@8.4.31`, pinned exactly by Next. Our own direct postcss
was already 8.5.32 and therefore patched, so the finding came entirely from the transitive copy.

There is **no patched Next 15.x**: `next@15.5.28` is the newest in that line and still pins 8.4.31.
npm's only suggested remedy was a **major** upgrade to `next@16.4.3`, which is a large amount of risk
to remove a build-time-only finding.

Instead, `site/package.json` gained:

```json
"overrides": { "postcss": "^8.5.32" }
```

postcss 8.5 is API-compatible with 8.4, so forcing it is low risk, and this was verified rather than
assumed: the build compiles and all 66 pages generate against 8.5.32, and the site gate passes all
seven checks. `npm audit` now reports **0 vulnerabilities** and only one postcss copy exists on disk.

### Is the advisory actually reachable?

No, and this is the part worth keeping. The advisories (GHSA-6g55-p6wh-862q, GHSA-r28c-9q8g-f849,
GHSA-qx2v-vp2m-jg93, GHSA-fxqj-rqcc-2cmp) are about postcss processing **untrusted CSS**: arbitrary
file read through a `sourceMappingURL` comment, and escaping in stringify output. In this project
postcss runs only at build time, over our own Tailwind and stylesheet files. No user can supply CSS
to this site. The finding was real; the exposure was nil. It is fixed anyway because the override
costs nothing.

## Semgrep: clean

Semgrep 1.136.0 installed into a virtualenv (it tolerates Python 3.9, which is why it works where
VibeGuard's own installer did not).

```
semgrep scan --config p/security-audit --config p/owasp-top-ten --config p/secrets \
  --exclude node_modules --exclude .next --exclude .git \
  site/src tools supabase

Rules run        128
Files scanned    59
Findings         0
```

This is the check that matters most for this codebase, because the site renders user-authored HTML
through `renderBody`. Semgrep found no injection, no path traversal, no unsanitised sink and no
secret. That agrees with the existing `check:site` gate, which independently asserts that every
`dangerouslySetInnerHTML` starts with `renderBody(`, `plainText(` or `JSON.stringify(`.

## How to run this again

```bash
# VibeGuard, unpacked rather than installed
<scratchpad>/vgbin/vibeguard/vibeguard scan . --pack core

# dependencies, no install needed
cd site && npm audit

# code patterns
<scratchpad>/vg/bin/semgrep scan --config p/security-audit --config p/owasp-top-ten site/src
```

## Still not covered

- **Container and IaC scanning.** There is no Dockerfile, no Kubernetes manifest and no Terraform in
  this project, so Trivy and Checkov have nothing to say. Nothing is lost.
- **Runtime testing.** Semgrep reads code. It cannot prove that a row-level security policy behaves,
  which is what `tools/dbcheck` is for, and it cannot prove that a live header is set. The Supabase
  posture was verified by probing the live API, and the tables that leak were found that way, not by
  any scanner.
- **The client bundle.** The publishable Supabase key ships to the browser by design. That is correct
  and intended. The service role key is not in this repository; if it ever appears in the client
  bundle, `check:site` fails the build.
