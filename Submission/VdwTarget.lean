import Submission.ProgressionColoring.Main

/-! Target adapter (mirror of `challenges/van-der-waerden/Target.lean`) against the
vendored corpus solution. `Bound c` is the corpus statement with `1/20000` replaced
by a free rational `c` (larger `c` better). `W`, `MonoAP`, `IsRamsey` come from the
vendored `Model.lean`, byte-identical to the frozen challenge statement
(`challenges/van-der-waerden/Statement.lean`). The proof is an assembly of the
cataloged, gap-free (no placeholder) openai/math `ProgressionColoring` solution. -/
namespace BigOSpeedrun.VanDerWaerden

open OAI.QuantitativeVanDerWaerden

/-- Quantitative van der Waerden lower bound at exponent constant `c`. -/
def Bound (c : ℚ) : Prop :=
  ∃ K : ℕ, ∀ k ≥ K, ∀ r ≥ 2,
    (k : ℝ) ^ ((c : ℝ) * k * (Nat.log 2 r : ℝ)) < (W r k : ℝ)

/-- The rung-2 instance `c = 1/20000`, bridged from the assembled solution: every
structural parameter (dimension 1/10, cutoff 1/2, flip 1/20) is the frozen corpus
block; only the budget envelope constant is retuned (2c − 1/8000 = −1/40000). -/
theorem bound_baseline : Bound ((1 : ℚ) / 20000) := by
  have h := OAI.QuantitativeVanDerWaerden.uniform_lower_bound
  simpa [Bound, Rat.cast_div, Rat.cast_ofNat, Rat.cast_one] using h

end BigOSpeedrun.VanDerWaerden
