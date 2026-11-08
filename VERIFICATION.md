# Verification receipt

Recorded evidence for the claim "GREEN 6/6". This is a **captured run**, not a
summary: the text in the block below is the verbatim stdout of `bash verify.sh`
on the commit named, plus the one build-log line the harness redirects to
`logs_verify_build.txt` (gitignored, like `logs_axioms.txt`; both are copied
here so the receipt is self-contained).

---

## Rung 2 — c = 1/20000 (branch `rung-2`)

Retune-only rung: 21 changed lines against rung-1, all constant selections
(`Parameters.c`, envelope constant, literal instantiations). Every structural
parameter and all 117 vendored corpus modules are byte-identical to rung-1.
Full project build from source (Mathlib oleans from `lake exe cache get`).

| | |
|---|---|
| Commit verified | `2c748a33cfbef402b7b39cb76ae0c429409698fa` |
| Branch | `rung-2`, tag `rung-2-1/20000` |
| Date (UTC) | Sun Nov  8 05:23:49 UTC 2026 |
| Lean | 4.34.1, arm64-apple-darwin24.6.0, commit `5045d0056413266e57c625dcd7c365b10e377c52` (Release) |
| Mathlib | `d13f23b723b8a846827a245b89c10fc7d3f11612` (`lake-manifest.json`) |
| Command | `bash verify.sh` |
| Result | exit 0, `GREEN 6/6` |

```
Sun Nov  8 05:23:49 UTC 2026
commit: 2c748a33cfbef402b7b39cb76ae0c429409698fa
branch: rung-2
lean: Lean (version 4.34.1, arm64-apple-darwin24.6.0, commit 5045d0056413266e57c625dcd7c365b10e377c52, Release)
$ bash verify.sh
== check 2: zero sorry (glue + vendored tree)
OK: no sorry
== check 1: lake build
build exit=0
== check 3+4+6: independent replay (axioms + autoImplicit=false + bare-import dry-run)
replay exit=0
'BigOSpeedrun.VanDerWaerden.bound_baseline' depends on axioms: [propext, Classical.choice, Quot.sound]
OK: axioms exactly {propext, Classical.choice, Quot.sound}
OK: bare-import audit (no opens)
== check 5: statement byte-exact vs corpus (sha256)
statement sha: 1caa563bbf7a5602adb8cdbbc06aaf1e3d4d5fe27ed4bebf2bf44cf2937a6593
target    sha: 1caa563bbf7a5602adb8cdbbc06aaf1e3d4d5fe27ed4bebf2bf44cf2937a6593
OK: statement byte-exact to corpus (1caa563bbf7a5602adb8cdbbc06aaf1e3d4d5fe27ed4bebf2bf44cf2937a6593)
== verdict: GREEN 6/6
VERIFY_EXIT=0
--- logs_verify_build.txt ---
Build completed successfully (9041 jobs).
```

This receipt is from a full `lake build` of the entire project (9041 jobs:
Mathlib fingerprint-replayed from fetched oleans, all 117 vendored `Submission/`
modules compiled from source at commit `2c748a3`), taken across three `lake build`
invocations on a host killing long builds with SIGTERM under concurrent fleet
load; lake's fingerprinting makes the retries resume, so the composed build is
equivalent to one uninterrupted run of the same committed sources. The host also
runs concurrent Lean builds from other projects; peak-RAM conditions are not
controlled by this receipt.

---

## Rung 1 — c = 1/100000 (tag `rung-1`, historical baseline)

| | |
|---|---|
| Commit verified | `3b09963bc632690b7600ced1eac4f0c2324f1c38` |
| Date (UTC) | Thu Nov  5 03:13:47 UTC 2026 |
| Lean | 4.34.1, arm64-apple-darwin24.6.0, commit `5045d0056413266e57c625dcd7c365b10e377c52` (Release) |
| Mathlib | `d13f23b723b8a846827a245b89c10fc7d3f11612` (`lake-manifest.json`) |
| Command | `bash verify.sh` |
| Result | exit 0, `GREEN 6/6` |

```
Thu Nov  5 03:13:47 UTC 2026
commit: 3b09963bc632690b7600ced1eac4f0c2324f1c38
lean: Lean (version 4.34.1, arm64-apple-darwin24.6.0, commit 5045d0056413266e57c625dcd7c365b10e377c52, Release)
$ bash verify.sh
== check 2: zero sorry (glue + vendored tree)
OK: no sorry
== check 1: lake build
build exit=0
== check 3+4+6: independent replay (axioms + autoImplicit=false + bare-import dry-run)
replay exit=0
'BigOSpeedrun.VanDerWaerden.bound_baseline' depends on axioms: [propext, Classical.choice, Quot.sound]
OK: axioms exactly {propext, Classical.choice, Quot.sound}
OK: bare-import audit (no opens)
== check 5: statement byte-exact vs corpus (sha256)
statement sha: 1caa563bbf7a5602adb8cdbbc06aaf1e3d4d5fe27ed4bebf2bf44cf2937a6593
target    sha: 1caa563bbf7a5602adb8cdbbc06aaf1e3d4d5fe27ed4bebf2bf44cf2937a6593
OK: statement byte-exact to corpus (1caa563bbf7a5602adb8cdbbc06aaf1e3d4d5fe27ed4bebf2bf44cf2937a6593)
== verdict: GREEN 6/6
VERIFY_EXIT=0
--- logs_verify_build.txt ---
✔ [9040/9041] Built Submission (36s)
Build completed successfully (9041 jobs).
```

## What was actually compiled

Be precise about this: **the receipt is from a warm `.lake`, not a cold clone.**

- The `Submission` root module — the file that states `Race.bound` — was
  force-recompiled for this receipt (its `olean`/`ilean`/`trace` were deleted
  first). Hence `Built Submission (36s)` in the log, not a replay.
- `AxiomCheck.lean` is not a library target; check 6 elaborates it from source on
  every run, so the axiom line above comes from freshly elaborated code.
- Mathlib, and the rest of the vendored `Submission/` tree, came from oleans
  already present in that build tree, produced from these same committed sources
  at this same commit. No `lake exe cache get` and no full Mathlib compile was
  performed for this receipt, so nothing here demonstrates a from-scratch
  Mathlib build.

## Reproducing from a cold clone

```bash
git clone https://github.com/darkhipo/vdw-first-rung
cd vdw-first-rung
lake exe cache get      # Mathlib oleans for the pinned rev (minutes)
lake build              # full project build from source
bash verify.sh          # 6-check harness -> GREEN 6/6, exit 0
```

Costs on the recording machine: ~8 GB of `.lake` and a Mathlib cache fetch; the
harness's `lake build` step is the only long one.

## Known gaps

- No CI. This receipt is a hand-captured run; nothing re-checks the claim on new
  commits. A `.lean`-only change that broke the build would not be caught
  automatically.
- `verify.sh` depends on the local `lake`/`lean` on `PATH` and on network access
  only through `lake exe cache get` (not through `verify.sh` itself).
- The corpus byte-exactness check compares against a hardcoded sha256
  (`1caa563b…`), so it validates that the two committed files are unchanged, not
  that the upstream corpus at that commit still hashes the same today.
