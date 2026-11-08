import Submission.VdwTarget

/-! Submission root — the challenge target.

The verifier checks exactly `Race.bound` (targets.md). This is rung 2,
`c = 1/20000`: the rung-1 assembly machinery with only the budget envelope
constant retuned (lean-admissible ceiling 2c < 1/8000, i.e. c < 1/16000).
The proof is an assembly of the cataloged openai/math `ProgressionColoring` solution. -/

theorem Race.bound : BigOSpeedrun.VanDerWaerden.Bound ((1 : ℚ) / 20000) :=
  BigOSpeedrun.VanDerWaerden.bound_baseline
