import Submission.VdwTarget

/-! Submission root — the challenge target.

The verifier checks exactly `Race.bound` (targets.md). This is the baseline instance
`c = 1/100000`, which validates the assembly machinery; a filed row carries an
attained `c > 1/100000` (see `challenges/van-der-waerden/README.md`, margin note).
The proof is an assembly of the cataloged openai/math `ProgressionColoring` solution. -/

theorem Race.bound : BigOSpeedrun.VanDerWaerden.Bound ((1 : ℚ) / 100000) :=
  BigOSpeedrun.VanDerWaerden.bound_baseline
