# Quantitative van der Waerden — Lean-Verified rung 2 (c = 1/20000)

Kernel-checked Lean 4 proof of the second rung of the quantitative van der Waerden
ladder: the OpenAI `openai/math` corpus machinery with the exponent constant
retuned from the corpus's displayed `1/100000` to **`1/20000`** (5× the baseline):

```lean
theorem uniform_lower_bound :
    ∃ K : ℕ, ∀ k ≥ K, ∀ r ≥ 2,
      (k : ℝ) ^ ((1 / 20000 : ℝ) * k * (Nat.log 2 r : ℝ)) < (W r k : ℝ)
```

i.e. **W_r(k) > k^(k·⌊log₂ r⌋/20000)** uniformly over all color counts r ≥ 2, for all
large k. The submission entry is:

```lean
theorem Race.bound : BigOSpeedrun.VanDerWaerden.Bound ((1 : ℚ) / 20000) :=
  BigOSpeedrun.VanDerWaerden.bound_baseline
```

with `Bound c` the corpus statement carrying a free exact-rational constant `c`
(larger is better). The constant enters as the exact rational `(1 : ℚ) / 20000`
cast to ℝ — no floating point anywhere.

**Where the improvement comes from.** Every structural parameter of the corpus
construction (dimension `k^(1/10)`, cutoff `k^(1/2)`, flip probability `k^(-1/20)`,
mesh, cut scale) is unchanged. The coefficient is pinned by exactly one numeric
budget: the rich-progression union bound needs `2c < 1/8000` (i.e. `c < 1/16000`),
with the envelope constant `1/8000 − 2c`. The corpus pinned `c = 1/100000`
(envelope `21/200000`); rung 2 pins `c = 1/20000` (envelope `1/40000`, margin
`1/40000` before the `O(k^(1/10)·log k)` correction terms). The retune touches
only `Parameters.c`, the envelope constant in `ProbabilityScales`/
`PerturbationScales`, and the literal instantiations in `Main`/`CyclicWitness`
(21 changed lines; the full diff against rung-1 is the retune, nothing else).

## Status

- **Verdict: GREEN 6/6** (`bash verify.sh`) — captured run, with commit, Lean
  version and the exact stdout, in **`VERIFICATION.md`**. That receipt was taken
  on a warm `.lake` (cached Mathlib oleans, project modules replayed) with the
  `Submission` root force-recompiled; it is not a cold-clone build.
- **Axioms** (`#print axioms`, bare import, `autoImplicit=false` replay):
  ```
  'BigOSpeedrun.VanDerWaerden.bound_baseline' depends on axioms: [propext, Classical.choice, Quot.sound]
  ```
  No `sorryAx`, no project-specific axioms. Zero `sorry` in the glue and the entire
  vendored tree.
- **Statement byte-exactness**: `challenges/van-der-waerden/Statement.lean` is
  byte-identical (sha256 `1caa563bbf7a5602adb8cdbbc06aaf1e3d4d5fe27ed4bebf2bf44cf2937a6593`)
  to `lean/ComparatorChallenges/QuantitativeVanDerWaerden.lean` in openai/math at
  commit `1581d4cbdd69a0faf34b2089614fe2a814316a6a` — including that file's `sorry`,
  which is OpenAI's *challenge placeholder* (the claim), not an assumed proof.

## Attribution

- **Mathematics and formalization**: OpenAI, `openai/math`
  (https://github.com/openai/math, Apache-2.0), commit
  `1581d4cbdd69a0faf34b2089614fe2a814316a6a`. The proof is an **assembly of the
  cataloged, sorry-free corpus solution**
  `lean/OAI/Combinatorics/ProgressionColoring/` (117 files), closing at
  `OAI.QuantitativeVanDerWaerden.uniform_lower_bound`
  (`exact uniform_lower_of_cyclicLowerBound exists_cyclic_coloring`). Full credit
  to the openai/math authors for the construction and its formalization.
- **Target adapter + 6-check harness**: `darkhipo/van-der-waerden` (MultiAgency
  swarm, Apache-2.0) at commit `60ef7e6` — the `BigOSpeedrun.VanDerWaerden.Bound`
  c-parameter adapter, the frozen statement folder, and the immunization harness.
- **This repo**: publication of the baseline (c = 1/100000) first rung as its own
  immutable package, with repository line endings normalized (CRLF → LF; content
  unchanged, byte-exactness restored against the corpus).

## Exact build commands

Pins: Lean `leanprover/lean4:v4.34.1`, Mathlib `d13f23b723b8a846827a245b89c10fc7d3f11612`
(`lean-toolchain`, `lakefile.toml`, `lake-manifest.json`).

```bash
lake build                     # Build completed successfully (9041 jobs).
lake env lean -DautoImplicit=false AxiomCheck.lean
# 'BigOSpeedrun.VanDerWaerden.bound_baseline' depends on axioms:
#   [propext, Classical.choice, Quot.sound]
bash verify.sh                 # 6-check immunization harness → GREEN 6/6
```

`verify.sh` checks: (1) `lake build` green; (2) zero `sorry`; (3) axioms exactly
`{propext, Classical.choice, Quot.sound}`; (4) `autoImplicit=false` clean;
(5) statement byte-exact vs corpus sha256; (6) bare-import audit (no `open`).

The recorded output of that command — stdout, exit status, commit, toolchain and
what was actually recompiled — is committed as `VERIFICATION.md`. There is no
CI; that file is the evidence, and it is a point-in-time capture.

## Scope and the ladder

This branch carries **rung 2**: the weakest Verified constant strictly better than
the corpus baseline, obtained by pure retuning of the already-kernel-checked
machinery (no new mathematics). The lean-admissible ceiling of this retune family
is `c < 1/16000`; rung 2 sits at `1/20000` with a strict margin. Going past
`1/16000` requires modifying the budget step itself (e.g. the conditional
"shorter dilation" modification of the DaysSky refinement), which is **not**
formalized anywhere. Stronger *claimed* ladders (DaysSky's conditional `c = 1/9`,
region `c < 1/8`) are **not** included here — their structural lemmas are
prose-only and their own status line disclaims formal verification. Nothing in
this repo depends on them.

## License

Apache-2.0 (matching openai/math and the adapter lineage).
