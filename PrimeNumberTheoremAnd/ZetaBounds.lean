import Mathlib.Analysis.Calculus.ContDiff.Defs
import Mathlib.MeasureTheory.Integral.IntervalIntegral
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.NumberTheory.ZetaFunction
import Mathlib.Algebra.Group.Basic
import EulerProducts.PNT
import PrimeNumberTheoremAnd.ResidueCalcOnRectangles
import PrimeNumberTheoremAnd.MellinCalculus
import Mathlib.MeasureTheory.Function.Floor
import Mathlib.Analysis.Complex.CauchyIntegral
import Mathlib.NumberTheory.Harmonic.Bounds

-- only importing the following for the MeasurableDiv₂ ℝ instance.
-- should remove eventually
import PrimeNumberTheoremAnd.PerronFormula

-- set_option quotPrecheck false
open BigOperators Complex Topology Filter Interval Set

lemma div_cpow_eq_cpow_neg (a x s : ℂ) : a / x ^ s = a * x ^ (-s) := by
  rw [div_eq_mul_inv, cpow_neg]

lemma one_div_cpow_eq_cpow_neg (x s : ℂ) : 1 / x ^ s = x ^ (-s) := by
  convert div_cpow_eq_cpow_neg 1 x s using 1; simp

lemma div_rpow_eq_rpow_neg (a x s : ℝ) (hx : 0 ≤ x): a / x ^ s = a * x ^ (-s) := by
  rw [div_eq_mul_inv, Real.rpow_neg hx]

lemma div_rpow_neg_eq_rpow_div {x y s : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) :
    x ^ (-s) / y ^ (-s) = (y / x) ^ s := by
  rw [div_eq_mul_inv, Real.rpow_neg hx, Real.rpow_neg hy, Real.div_rpow hy hx]; field_simp

lemma div_rpow_eq_rpow_div_neg {x y s : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) :
    x ^ s / y ^ s = (y / x) ^ (-s) := by
  convert div_rpow_neg_eq_rpow_div (s := -s) hx hy using 1; simp only [neg_neg]

/-%%
\begin{definition}[RiemannZeta0]\label{RiemannZeta0}\lean{RiemannZeta0}\leanok
\uses{ZetaSum_aux2}
For any natural $N\ge1$, we define
$$
\zeta_0(N,s) :=
\sum_{1\le n < N} \frac1{n^s}
+
\frac{- N^{1-s}}{1-s} + \frac{-N^{-s}}{2} + s \int_N^\infty \frac{\lfloor x\rfloor + 1/2 - x}{x^{s+1}} \, dx
$$
\end{definition}
%%-/
noncomputable def riemannZeta0 (N : ℕ) (s : ℂ) : ℂ :=
  (∑ n in Finset.range N, 1 / (n : ℂ) ^ s) +
  (- N ^ (1 - s)) / (1 - s) + (- N ^ (-s)) / 2
      + s * ∫ x in Ioi (N : ℝ), (⌊x⌋ + 1 / 2 - x) / (x : ℂ) ^ (s + 1)

/-- We use `ζ` to denote the Rieman zeta function and `ζ₀` to denote the alternative
  Rieman zeta function.. -/
local notation (name := riemannzeta) "ζ" => riemannZeta
local notation (name := riemannzeta0) "ζ₀" => riemannZeta0

lemma riemannZeta0_apply (N : ℕ) (s : ℂ) : ζ₀ N s =
    (∑ n in Finset.range N, 1 / (n : ℂ) ^ s) +
    ((- N ^ (1 - s)) / (1 - s) + (- N ^ (-s)) / 2
      + s * ∫ x in Ioi (N : ℝ), (⌊x⌋ + 1 / 2 - x) * (x : ℂ) ^ (-(s + 1))) := by
  simp_rw [riemannZeta0, div_cpow_eq_cpow_neg]; ring

-- lemma AnalyticContinuation {f g : ℂ → ℂ} {s t : Set ℂ} (f_on_s : AnalyticOn ℂ f s)
--     (g_on_t : AnalyticOn ℂ g t) (f_eq_g_on_cap : EqOn f g (s ∩ t))
--     (s_open : IsOpen s) (t_open : IsOpen t) (cap_nonempty : Nonempty (s ∩ t)) :
--     ∃! h : ℂ → ℂ, AnalyticOn ℂ h (s ∪ t) ∧ EqOn h f s ∧ EqOn h g t := by
--   classical
--   let h : ℂ → ℂ := fun z ↦ if z ∈ s then f z else g z
--   refine ⟨h, ⟨?_, fun z hz ↦ by simp [h, hz], ?_⟩, ?_⟩
--   · sorry
--   · intro z hz
--     by_cases z_in_s : z ∈ s
--     · have : z ∈ s ∩ t := by simp [z_in_s, hz]
--       have := f_eq_g_on_cap this
--       simp [h, z_in_s, this]
--     · simp [h, z_in_s]
--   · intro h' ⟨h'_analytic, h'_eq_f_on_s, h'_eq_g_on_t⟩
--     sorry

-- lemma AnalyticContinuation' {f g : ℂ → ℂ} {s t u : Set ℂ} (f_on_s : AnalyticOn ℂ f s)
--     (g_on_t : AnalyticOn ℂ g t) (u_sub : u ⊆ s ∩ t) (u_open : IsOpen u)
--     (u_nonempty : Nonempty u) (f_eq_g_on_u : EqOn f g u) :
--     EqOn f g (s ∩ t) := by
--   sorry

-- move near `Real.differentiableAt_rpow_const_of_ne`
lemma Real.differentiableAt_cpow_const_of_ne (s : ℂ) {x : ℝ} (xpos : 0 < x) :
    DifferentiableAt ℝ (fun (x : ℝ) ↦ (x : ℂ) ^ s) x := by
  apply DifferentiableAt.comp_ofReal (e := fun z ↦ z ^ s)
  apply DifferentiableAt.cpow (by simp) (by simp) (by simp [xpos])

lemma Complex.one_div_cpow_eq {s : ℂ} {x : ℝ} (x_ne : x ≠ 0) :
    1 / (x : ℂ) ^ s = (x : ℂ) ^ (-s) := by
  refine (eq_one_div_of_mul_eq_one_left ?_).symm
  rw [← cpow_add _ _ <| mod_cast x_ne, add_left_neg, cpow_zero]

-- No longer used
lemma ContDiffOn.hasDeriv_deriv {φ : ℝ → ℂ} {s : Set ℝ} (φDiff : ContDiffOn ℝ 1 φ s) {x : ℝ}
    (x_in_s : s ∈ nhds x) : HasDerivAt φ (deriv φ x) x :=
  (ContDiffAt.hasStrictDerivAt (φDiff.contDiffAt x_in_s) (by simp)).hasDerivAt

-- No longer used
lemma ContDiffOn.continuousOn_deriv {φ : ℝ → ℂ} {a b : ℝ}
    (φDiff : ContDiffOn ℝ 1 φ (uIoo a b)) :
    ContinuousOn (deriv φ) (uIoo a b) := by
  apply ContDiffOn.continuousOn (𝕜 := ℝ) (n := 0)
  exact (fun h ↦ ((contDiffOn_succ_iff_deriv_of_isOpen isOpen_Ioo).1 h).2) φDiff

lemma LinearDerivative_ofReal (x : ℝ) (a b : ℂ) : HasDerivAt (fun (t : ℝ) ↦ a * t + b) a x := by
  refine HasDerivAt.add_const ?_ b
  convert (ContinuousLinearMap.hasDerivAt Complex.ofRealCLM).const_mul a using 1; simp
-- No longer used
section
-- from Floris van Doorn

variable {A : Type*} [NormedRing A] [NormedAlgebra ℝ A] [CompleteSpace A] {a b : ℝ}

set_option autoImplicit false in
open BigOperators Interval Topology Set intervalIntegral MeasureTheory in
lemma integral_deriv_mul_eq_sub' {u v u' v' : ℝ → A}
    (hu : ∀ x ∈ [[a, b]], HasDerivWithinAt u (u' x) [[a, b]] x)
    (hv : ∀ x ∈ [[a, b]], HasDerivWithinAt v (v' x) [[a, b]] x)
    (hu' : IntervalIntegrable u' volume a b)
    (hv' : IntervalIntegrable v' volume a b) :
    ∫ x in a..b, u' x * v x + u x * v' x = u b * v b - u a * v a := by
  have h2u : ContinuousOn u [[a, b]] := fun x hx ↦ (hu x hx).continuousWithinAt
  have h2v : ContinuousOn v [[a, b]] := fun x hx ↦ (hv x hx).continuousWithinAt
  apply integral_eq_sub_of_hasDeriv_right (h2u.mul h2v)
  · exact fun x hx ↦ (hu x <| mem_Icc_of_Ioo hx).mul (hv x <| mem_Icc_of_Ioo hx) |>.hasDerivAt
      (Icc_mem_nhds hx.1 hx.2) |>.hasDerivWithinAt
  · exact (hu'.mul_continuousOn h2v).add (hv'.continuousOn_mul h2u)

end

lemma sum_eq_int_deriv_aux2 {φ : ℝ → ℂ} {a b : ℝ} (c : ℂ)
    (φDiff : ∀ x ∈ [[a, b]], HasDerivAt φ (deriv φ x) x)
    (derivφCont : ContinuousOn (deriv φ) [[a, b]]) :
    ∫ (x : ℝ) in a..b, (c - x) * deriv φ x =
      (c - b) * φ b - (c - a) * φ a + ∫ (x : ℝ) in a..b, φ x := by
  set u := fun (x : ℝ) ↦ c - x
  set u' := fun (x : ℝ) ↦ (-1 : ℂ)
  have hu : ∀ x ∈ uIcc a b, HasDerivAt u (u' x) x := by
    exact fun x _ ↦ by convert LinearDerivative_ofReal x (-1 : ℂ) c; ring
  have hu' : IntervalIntegrable u' MeasureTheory.volume a b := by
    apply Continuous.intervalIntegrable; continuity
  have hv' : IntervalIntegrable (deriv φ) MeasureTheory.volume a b :=
    derivφCont.intervalIntegrable
  convert intervalIntegral.integral_mul_deriv_eq_deriv_mul hu φDiff hu' hv' using 1; simp [u]

lemma sum_eq_int_deriv_aux_eq {φ : ℝ → ℂ} {a b : ℝ} {k : ℤ}
    (b_eq_kpOne : b = k + 1) (φDiff : ∀ x ∈ [[a, b]], HasDerivAt φ (deriv φ x) x)
    (derivφCont : ContinuousOn (deriv φ) [[a, b]]) :
    ∑ n in Finset.Ioc k ⌊b⌋, φ n =
    (∫ x in a..b, φ x) + (⌊b⌋ + 1 / 2 - b) * φ b - (k + 1 / 2 - a) * φ a
      - ∫ x in a..b, (k + 1 / 2 - x) * deriv φ x := by
  have flb_eq_k : ⌊b⌋ = k + 1 := Int.floor_eq_iff.mpr ⟨by exact_mod_cast b_eq_kpOne.symm.le,
    by rw [b_eq_kpOne]; simp⟩
  simp only [flb_eq_k, Finset.Icc_self, Finset.sum_singleton, Int.cast_add, Int.cast_one]
  rw [sum_eq_int_deriv_aux2 (k + 1 / 2) φDiff derivφCont, b_eq_kpOne]
  ring_nf
  have : Finset.Ioc k (1 + k) = {k + 1} := by
    ext m
    simp only [Finset.mem_Ioc, Finset.mem_singleton]
    constructor
    · exact fun ⟨h₁, h₂⟩ ↦ by rw [add_comm] at h₂; exact Int.le_antisymm h₂ h₁
    · exact fun h ↦ ⟨by simp [h], by simp [h, add_comm]⟩
  simp_rw [this, Finset.sum_singleton, Int.cast_add, Int.cast_one, add_comm]

lemma sum_eq_int_deriv_aux_lt {φ : ℝ → ℂ} {a b : ℝ} {k : ℤ} (ha : a ∈ Ico (k : ℝ) b)
    (b_lt_kpOne : b < k + 1) (φDiff : ∀ x ∈ [[a, b]], HasDerivAt φ (deriv φ x) x)
    (derivφCont : ContinuousOn (deriv φ) [[a, b]]) :
    ∑ n in Finset.Ioc k ⌊b⌋, φ n =
    (∫ x in a..b, φ x) + (⌊b⌋ + 1 / 2 - b) * φ b - (k + 1 / 2 - a) * φ a
      - ∫ x in a..b, (k + 1 / 2 - x) * deriv φ x := by
  have flb_eq_k : ⌊b⌋ = k := Int.floor_eq_iff.mpr ⟨by linarith [ha.1, ha.2], by linarith⟩
  simp only [flb_eq_k, gt_iff_lt, lt_add_iff_pos_right, zero_lt_one, Finset.Icc_eq_empty_of_lt,
    Finset.sum_empty]
  rw [sum_eq_int_deriv_aux2 (k + 1 / 2) φDiff derivφCont]
  have : Finset.Ioc k k = {} := by simp only [ge_iff_le, le_refl, Finset.Ioc_eq_empty_of_le]
  simp only [this, Finset.sum_empty, one_div]; ring_nf

lemma sum_eq_int_deriv_aux1 {φ : ℝ → ℂ} {a b : ℝ} {k : ℤ} (ha : a ∈ Ico (k : ℝ) b)
    (b_le_kpOne : b ≤ k + 1) (φDiff : ∀ x ∈ [[a, b]], HasDerivAt φ (deriv φ x) x)
    (derivφCont : ContinuousOn (deriv φ) [[a, b]]) :
    ∑ n in Finset.Ioc k ⌊b⌋, φ n =
    (∫ x in a..b, φ x) + (⌊b⌋ + 1 / 2 - b) * φ b - (k + 1 / 2 - a) * φ a
      - ∫ x in a..b, (k + 1 / 2 - x) * deriv φ x := by
  by_cases h : b = k + 1
  · exact sum_eq_int_deriv_aux_eq h φDiff derivφCont
  · exact sum_eq_int_deriv_aux_lt ha (Ne.lt_of_le h b_le_kpOne) φDiff derivφCont

/-%%
\begin{lemma}[sum_eq_int_deriv_aux]\label{sum_eq_int_deriv_aux}\lean{sum_eq_int_deriv_aux}\leanok
  Let $k \le a < b\le k+1$, with $k$ an integer, and let $\phi$ be continuously differentiable on
  $[a, b]$.
  Then
  \[
  \sum_{a < n \le b} \phi(n) = \int_a^b \phi(x) \, dx + \left(\lfloor b \rfloor + \frac{1}{2} - b\right) \phi(b) - \left(\lfloor a \rfloor + \frac{1}{2} - a\right) \phi(a) - \int_a^b \left(\lfloor x \rfloor + \frac{1}{2} - x\right) \phi'(x) \, dx.
  \]
\end{lemma}
%%-/
lemma sum_eq_int_deriv_aux {φ : ℝ → ℂ} {a b : ℝ} {k : ℤ} (ha : a ∈ Ico (k : ℝ) b)
    (b_le_kpOne : b ≤ k + 1) (φDiff : ∀ x ∈ [[a, b]], HasDerivAt φ (deriv φ x) x)
    (derivφCont : ContinuousOn (deriv φ) [[a, b]]) :
    ∑ n in Finset.Ioc ⌊a⌋ ⌊b⌋, φ n =
    (∫ x in a..b, φ x) + (⌊b⌋ + 1 / 2 - b) * φ b - (⌊a⌋ + 1 / 2 - a) * φ a
      - ∫ x in a..b, (⌊x⌋ + 1 / 2 - x) * deriv φ x := by
  have fl_a_eq_k : ⌊a⌋ = k := Int.floor_eq_iff.mpr ⟨ha.1, by linarith [ha.2]⟩
  convert sum_eq_int_deriv_aux1 ha b_le_kpOne φDiff derivφCont using 2
  · rw [fl_a_eq_k]
  · congr
  · apply intervalIntegral.integral_congr_ae
    have : ∀ᵐ (x : ℝ) ∂MeasureTheory.volume, x ≠ b := by
      convert Countable.ae_not_mem (s := {b}) (by simp) (μ := MeasureTheory.volume) using 1
    filter_upwards [this]
    intro x x_ne_b hx
    rw [uIoc_of_le ha.2.le, mem_Ioc] at hx
    congr
    exact Int.floor_eq_iff.mpr ⟨by linarith [ha.1], by have := Ne.lt_of_le x_ne_b hx.2; linarith⟩
/-%%
\begin{proof}\leanok
Partial integration.
\end{proof}
%%-/

-- Thanks to Arend Mellendijk

lemma interval_induction_aux_int (n : ℕ) : ∀ (P : ℝ → ℝ → Prop)
    (_ : ∀ a b : ℝ, ∀ k : ℤ, k ≤ a → a < b → b ≤ k + 1 → P a b)
    (_ : ∀ (a : ℝ) (k : ℤ) (c : ℝ), a < k → k < c → P a k → P k c → P a c)
    (a b : ℝ) (_ : a < b) (_ : n = ⌊b⌋ - ⌊a⌋),
    P a b := by
  induction n using Nat.case_strong_induction_on with
  | hz =>
    intro P base _ a b hab hn
    apply base a b ⌊a⌋ (Int.floor_le a) hab
    rw [(by simp only [CharP.cast_eq_zero] at hn; linarith : ⌊a⌋ = ⌊b⌋)]
    exact (Int.lt_floor_add_one b).le
  | hi n ih =>
    intro P base step a b _ hn
    have Pa : P a (⌊a⌋ + 1) :=
      base a (⌊a⌋ + 1) ⌊a⌋ (Int.floor_le a) (Int.lt_floor_add_one a) (le_of_eq rfl)
    by_cases b_le_flaP1 : b = ⌊a⌋ + 1
    · rwa [b_le_flaP1]
    have flaP1_lt_b : ⌊a⌋ + 1 < b := by
      simp only [Nat.cast_succ] at hn
      have : (⌊a⌋ : ℝ) + 1 ≤ ⌊b⌋ := by exact_mod_cast (by linarith)
      exact Ne.lt_of_le (id (Ne.symm b_le_flaP1)) (by linarith [Int.floor_le b] : ⌊a⌋ + 1 ≤ b)
    have Pfla_b : P (⌊a⌋ + 1) b := by
      apply ih n (le_of_eq rfl) P base step (⌊a⌋ + 1) b flaP1_lt_b
      simp only [Int.floor_add_one, Int.floor_intCast, Nat.cast_succ] at hn ⊢
      linarith
    refine step a (⌊a⌋ + 1) b ?_ (by exact_mod_cast flaP1_lt_b) (by exact_mod_cast Pa)
      (by exact_mod_cast Pfla_b)
    have := Int.lt_floor_add_one a
    exact_mod_cast this

lemma interval_induction (P : ℝ → ℝ → Prop)
    (base : ∀ a b : ℝ, ∀ k : ℤ, k ≤ a → a < b → b ≤ k + 1 → P a b)
    (step : ∀ (a : ℝ) (k : ℤ) (b : ℝ), a < k → k < b → P a k → P k b → P a b)
    (a b : ℝ) (hab : a < b) : P a b := by
  set n := ⌊b⌋ - ⌊a⌋ with hn
  clear_value n
  have : 0 ≤ n := by simp only [hn, sub_nonneg, ge_iff_le, Int.floor_le_floor _ _ (hab.le)]
  lift n to ℕ using this
  exact interval_induction_aux_int n P base step a b hab hn

/-%%
\begin{lemma}[sum_eq_int_deriv]\label{sum_eq_int_deriv}\lean{sum_eq_int_deriv}\leanok
  Let $a < b$, and let $\phi$ be continuously differentiable on $[a, b]$.
  Then
  \[
  \sum_{a < n \le b} \phi(n) = \int_a^b \phi(x) \, dx + \left(\lfloor b \rfloor + \frac{1}{2} - b\right) \phi(b) - \left(\lfloor a \rfloor + \frac{1}{2} - a\right) \phi(a) - \int_a^b \left(\lfloor x \rfloor + \frac{1}{2} - x\right) \phi'(x) \, dx.
  \]
\end{lemma}
%%-/
/-- ** Partial summation ** (TODO : Add to Mathlib). -/
theorem Finset.Ioc_diff_Ioc {α : Type*} [LinearOrder α] [LocallyFiniteOrder α]
    {a b c: α} [DecidableEq α] (hb : b ∈ Icc a c) : Ioc a b = Ioc a c \ Ioc b c := by
  ext x
  simp only [mem_Ioc, mem_sdiff, not_and, not_le]
  constructor
  · refine fun ⟨h₁, h₂⟩ ↦ ⟨⟨h₁, le_trans h₂ (mem_Icc.mp hb).2⟩, by contrapose! h₂; exact h₂.1⟩
  · exact fun ⟨h₁, h₂⟩ ↦ ⟨h₁.1, by contrapose! h₂; exact ⟨h₂, h₁.2⟩⟩

-- In Yaël Dillies's API (https://leanprover.zulipchat.com/#narrow/stream/217875-Is-there-code-for-X.3F/topic/Finset.2Esum_add_adjacent_intervals/near/430127101)
lemma Finset.sum_Ioc_add_sum_Ioc {a b c : ℤ} (f : ℤ → ℂ) (hb : b ∈ Icc a c):
    (∑ n in Finset.Ioc a b, f n) + (∑ n in Finset.Ioc b c, f n) = ∑ n in Finset.Ioc a c, f n := by
  convert Finset.sum_sdiff (s₁ := Finset.Ioc b c) (s₂ := Finset.Ioc a c) ?_
  · exact Finset.Ioc_diff_Ioc hb
  · exact Finset.Ioc_subset_Ioc (mem_Icc.mp hb).1 (by rfl)

lemma integrability_aux₀ {a b : ℝ} :
    ∀ᵐ (x : ℝ) ∂MeasureTheory.Measure.restrict MeasureTheory.volume [[a, b]],
      ‖(⌊x⌋ : ℂ)‖ ≤ max ‖a‖ ‖b‖ + 1 := by
  apply (MeasureTheory.ae_restrict_iff' measurableSet_Icc).mpr
  refine MeasureTheory.ae_of_all _ (fun x hx ↦ ?_)
  simp only [inf_le_iff, le_sup_iff, mem_Icc] at hx
  simp only [norm_int, Real.norm_eq_abs]
  have : |x| ≤ max |a| |b| := by
    cases' hx.1 with x_ge_a x_ge_b <;> cases' hx.2 with x_le_a x_le_b
    · rw [(by linarith : x = a)]; apply le_max_left
    · apply abs_le_max_abs_abs x_ge_a x_le_b
    · rw [max_comm]; apply abs_le_max_abs_abs x_ge_b x_le_a
    · rw [(by linarith : x = b)]; apply le_max_right
  cases' abs_cases x with hx hx
  · rw [_root_.abs_of_nonneg <| by exact_mod_cast Int.floor_nonneg.mpr hx.2]
    apply le_trans (Int.floor_le x) <| le_trans (hx.1 ▸ this) (by simp)
  · rw [_root_.abs_of_nonpos <| by exact_mod_cast Int.floor_nonpos hx.2.le]
    linarith [(Int.lt_floor_add_one x).le]

lemma integrability_aux₁ {a b : ℝ} :
    IntervalIntegrable (fun (x : ℝ) ↦ (⌊x⌋ : ℂ)) MeasureTheory.volume a b := by
  rw [intervalIntegrable_iff']
  apply MeasureTheory.Measure.integrableOn_of_bounded ?_ ?_ integrability_aux₀
  · simp only [Real.volume_interval, ne_eq, ENNReal.ofReal_ne_top, not_false_eq_true]
  · apply Measurable.aestronglyMeasurable
    apply Measurable.comp (by exact fun ⦃t⦄ _ ↦ trivial) Int.measurable_floor

lemma integrability_aux₂ {a b : ℝ} :
    IntervalIntegrable (fun (x : ℝ) ↦ (1 : ℂ) / 2 - x) MeasureTheory.volume a b :=
  ContinuousOn.intervalIntegrable <| Continuous.continuousOn (by continuity)

lemma integrability_aux {a b : ℝ} :
    IntervalIntegrable (fun (x : ℝ) ↦ (⌊x⌋ : ℂ) + 1 / 2 - x) MeasureTheory.volume a b := by
  convert integrability_aux₁.add integrability_aux₂ using 2; ring

lemma uIcc_subsets {a b c : ℝ} (hc : c ∈ Icc a b) :
    [[a, c]] ⊆ [[a, b]] ∧ [[c, b]] ⊆ [[a, b]] := by
  constructor <;> rw [uIcc_of_le ?_, uIcc_of_le ?_]
  any_goals apply Icc_subset_Icc
  all_goals linarith [hc.1, hc.2]

lemma sum_eq_int_deriv {φ : ℝ → ℂ} {a b : ℝ} (a_lt_b : a < b)
    (φDiff : ∀ x ∈ [[a, b]], HasDerivAt φ (deriv φ x) x)
    (derivφCont : ContinuousOn (deriv φ) [[a, b]]) :
    ∑ n in Finset.Ioc ⌊a⌋ ⌊b⌋, φ n =
      (∫ x in a..b, φ x) + (⌊b⌋ + 1 / 2 - b) * φ b - (⌊a⌋ + 1 / 2 - a) * φ a
        - ∫ x in a..b, (⌊x⌋ + 1 / 2 - x) * deriv φ x := by
  let P := fun a₁ b₁ ↦ (∀ x ∈ [[a₁, b₁]], HasDerivAt φ (deriv φ x) x) →
    (ContinuousOn (deriv φ) [[a₁, b₁]]) →
    ∑ n in Finset.Ioc ⌊a₁⌋ ⌊b₁⌋, φ n =
    (∫ x in a₁..b₁, φ x) + (⌊b₁⌋ + 1 / 2 - b₁) * φ b₁ - (⌊a₁⌋ + 1 / 2 - a₁) * φ a₁
      - ∫ x in a₁..b₁, (⌊x⌋ + 1 / 2 - x) * deriv φ x
  apply interval_induction P ?base ?step a b a_lt_b φDiff derivφCont
  · exact fun _ _ _ k₁_le_a₁ a₁_lt_b₁ b₁_le_k₁ φDiff₁ derivφCont₁ ↦
      sum_eq_int_deriv_aux ⟨k₁_le_a₁, a₁_lt_b₁⟩ b₁_le_k₁ φDiff₁ derivφCont₁
  · intro a₁ k₁ b₁ a₁_lt_k₁ k₁_lt_b₁ ih₁ ih₂ φDiff₁ derivφCont₁
    have subs := uIcc_subsets ⟨a₁_lt_k₁.le, k₁_lt_b₁.le⟩
    have s₁ := ih₁ (fun x hx ↦ φDiff₁ x <| subs.1 hx) <| derivφCont₁.mono subs.1
    have s₂ := ih₂ (fun x hx ↦ φDiff₁ x <| subs.2 hx) <| derivφCont₁.mono subs.2
    convert Mathlib.Tactic.LinearCombination.add_pf s₁ s₂ using 1
    · rw [← Finset.sum_Ioc_add_sum_Ioc]
      simp only [Finset.mem_Icc, Int.floor_intCast, Int.le_floor]
      exact ⟨Int.cast_le.mp <| le_trans (Int.floor_le a₁) a₁_lt_k₁.le, k₁_lt_b₁.le⟩
    · set I₁ := ∫ (x : ℝ) in a₁..b₁, φ x
      set I₂ := ∫ (x : ℝ) in a₁..k₁, φ x
      set I₃ := ∫ (x : ℝ) in k₁..b₁, φ x
      set J₁ := ∫ (x : ℝ) in a₁..b₁, (↑⌊x⌋ + 1 / 2 - ↑x) * deriv φ x
      set J₂ := ∫ (x : ℝ) in a₁..k₁, (↑⌊x⌋ + 1 / 2 - ↑x) * deriv φ x
      set J₃ := ∫ (x : ℝ) in k₁..b₁, (↑⌊x⌋ + 1 / 2 - ↑x) * deriv φ x
      have hI : I₂ + I₃ = I₁ := by
        apply intervalIntegral.integral_add_adjacent_intervals <;>
        apply ContinuousOn.intervalIntegrable
        · exact HasDerivAt.continuousOn <| fun x hx ↦ φDiff₁ x <| subs.1 hx
        · exact HasDerivAt.continuousOn <| fun x hx ↦ φDiff₁ x <| subs.2 hx
      have hJ : J₂ + J₃ = J₁ := by
        apply intervalIntegral.integral_add_adjacent_intervals <;>
        apply IntervalIntegrable.mul_continuousOn
        any_goals apply integrability_aux
        · exact derivφCont₁.mono subs.1
        · exact derivφCont₁.mono subs.2
      rw [← hI, ← hJ]; ring
/-%%
\begin{proof}\uses{sum_eq_int_deriv_aux}\leanok
  Apply Lemma \ref{sum_eq_int_deriv_aux} in blocks of length $\le 1$.
\end{proof}
%%-/

lemma xpos_of_uIcc {a b : ℕ} (ha : a ∈ Ioo 0 b) {x : ℝ} (x_in : x ∈ [[(a : ℝ), b]]) :
    0 < x := by
  rw [uIcc_of_le (by exact_mod_cast ha.2.le), mem_Icc] at x_in
  linarith [(by exact_mod_cast ha.1 : (0 : ℝ) < a)]

lemma neg_s_ne_neg_one {s : ℂ} (s_ne_one : s ≠ 1) : -s ≠ -1 := fun hs ↦ s_ne_one <| neg_inj.mp hs

lemma ZetaSum_aux1₁ {a b : ℕ} {s : ℂ} (s_ne_one : s ≠ 1) (ha : a ∈ Ioo 0 b) :
    (∫ (x : ℝ) in a..b, 1 / (x : ℂ) ^ s) =
    (b ^ (1 - s) - a ^ (1 - s)) / (1 - s) := by
  convert integral_cpow (a := a) (b := b) (r := -s) ?_ using 1
  · refine intervalIntegral.integral_congr fun x hx ↦ one_div_cpow_eq ?_
    exact (xpos_of_uIcc ha hx).ne'
  · norm_cast; rw [(by ring : -s + 1 = 1 - s)]
  · right; refine ⟨neg_s_ne_neg_one s_ne_one, ?_⟩
    exact fun hx ↦ (lt_self_iff_false 0).mp <| xpos_of_uIcc ha hx

lemma ZetaSum_aux1φDiff {s : ℂ} {x : ℝ} (xpos : 0 < x) :
    HasDerivAt (fun (t : ℝ) ↦ 1 / (t : ℂ) ^ s) (deriv (fun (t : ℝ) ↦ 1 / (t : ℂ) ^ s) x) x := by
  apply hasDerivAt_deriv_iff.mpr <| DifferentiableAt.div (differentiableAt_const _) ?_ ?_
  · exact Real.differentiableAt_cpow_const_of_ne s xpos
  · simp [cpow_eq_zero_iff, xpos.ne']

lemma ZetaSum_aux1φderiv {s : ℂ} (s_ne_zero : s ≠ 0) {x : ℝ} (xpos : 0 < x) :
    deriv (fun (t : ℝ) ↦ 1 / (t : ℂ) ^ s) x = (fun (x : ℝ) ↦ -s * (x : ℂ) ^ (-(s + 1))) x := by
  let r := -s - 1
  have r_add1_ne_zero : r + 1 ≠ 0 := fun hr ↦ by simp [neg_ne_zero.mpr s_ne_zero, r] at hr
  have r_ne_neg1 : r ≠ -1 := fun hr ↦ (hr ▸ r_add1_ne_zero) <| by norm_num
  have hasDeriv := hasDerivAt_ofReal_cpow xpos.ne' r_ne_neg1
  have := hasDeriv.deriv ▸ deriv_const_mul (-s) (hasDeriv).differentiableAt
  convert this using 2
  · ext y
    by_cases y_zero : (y : ℂ) = 0
    · simp only [y_zero, ofReal_zero, ne_eq, s_ne_zero, not_false_eq_true, zero_cpow, div_zero,
      r_add1_ne_zero, zero_div, mul_zero]
    · have : (y : ℂ) ^ s ≠ 0 := fun hy ↦ y_zero ((cpow_eq_zero_iff _ _).mp hy).1
      field_simp [r, mul_assoc, ← Complex.cpow_add]
  · ring_nf

lemma ZetaSum_aux1derivφCont {s : ℂ} (s_ne_zero : s ≠ 0) {a b : ℕ} (ha : a ∈ Ioo 0 b) :
    ContinuousOn (deriv (fun (t : ℝ) ↦ 1 / (t : ℂ) ^ s)) [[a, b]] := by
  have : EqOn _ (fun (t : ℝ) ↦ -s * (t : ℂ) ^ (-(s + 1))) [[a, b]] :=
    fun x hx ↦ ZetaSum_aux1φderiv s_ne_zero <| xpos_of_uIcc ha hx
  refine ContinuousOn.congr ?_ this
  refine (ContinuousOn.cpow_const continuous_ofReal.continuousOn ?_).const_smul (c := -s)
  exact fun x hx ↦ ofReal_mem_slitPlane.mpr <| xpos_of_uIcc ha hx

/-%%
\begin{lemma}[ZetaSum_aux1]\label{ZetaSum_aux1}\lean{ZetaSum_aux1}\leanok
  Let $0 < a < b$ be natural numbers and $s\in \C$ with $s \ne 1$ and $s \ne 0$.
  Then
  \[
  \sum_{a < n \le b} \frac{1}{n^s} =  \frac{b^{1-s} - a^{1-s}}{1-s} + \frac{b^{-s}-a^{-s}}{2} + s \int_a^b \frac{\lfloor x\rfloor + 1/2 - x}{x^{s+1}} \, dx.
  \]
\end{lemma}
%%-/
lemma ZetaSum_aux1 {a b : ℕ} {s : ℂ} (s_ne_one : s ≠ 1) (s_ne_zero : s ≠ 0) (ha : a ∈ Ioo 0 b) :
    ∑ n in Finset.Ioc (a : ℤ) b, 1 / (n : ℂ) ^ s =
    (b ^ (1 - s) - a ^ (1 - s)) / (1 - s) + 1 / 2 * (1 / b ^ (s)) - 1 / 2 * (1 / a ^ s)
      + s * ∫ x in a..b, (⌊x⌋ + 1 / 2 - x) * (x : ℂ) ^ (-(s + 1)) := by
  let φ := fun (x : ℝ) ↦ 1 / (x : ℂ) ^ s
  let φ' := fun (x : ℝ) ↦ -s * (x : ℂ) ^ (-(s + 1))
  have xpos : ∀ x ∈ [[(a : ℝ), b]], 0 < x := fun x hx ↦ xpos_of_uIcc ha hx
  have φDiff : ∀ x ∈ [[(a : ℝ), b]], HasDerivAt φ (deriv φ x) x := fun x hx ↦ ZetaSum_aux1φDiff (xpos x hx)
  have φderiv : ∀ x ∈ [[(a : ℝ), b]], deriv φ x = φ' x := by
    exact fun x hx ↦ ZetaSum_aux1φderiv s_ne_zero (xpos x hx)
  have derivφCont : ContinuousOn (deriv φ) [[a, b]] := ZetaSum_aux1derivφCont s_ne_zero ha
  convert sum_eq_int_deriv (by exact_mod_cast ha.2) φDiff derivφCont using 1
  · congr <;> simp only [Int.floor_natCast]
  · rw [Int.floor_natCast, Int.floor_natCast, ← intervalIntegral.integral_const_mul]
    simp_rw [mul_div, ← mul_div, ZetaSum_aux1₁ s_ne_one ha]
    conv => rhs; rw [sub_eq_add_neg]
    congr; any_goals norm_cast; simp only [one_div, add_sub_cancel_left]
    rw [← intervalIntegral.integral_neg, intervalIntegral.integral_congr]
    intro x hx; simp_rw [φderiv x hx, φ']; ring_nf
/-%%
\begin{proof}\uses{sum_eq_int_deriv}\leanok
  Apply Lemma \ref{sum_eq_int_deriv} to the function $x \mapsto x^{-s}$.
\end{proof}
%%-/

lemma ZetaSum_aux1_1' {a b x : ℝ} (apos : 0 < a) (hx : x ∈ Icc a b)
    : 0 < x := lt_of_lt_of_le apos hx.1

lemma ZetaSum_aux1_1 {a b x : ℝ} (apos : 0 < a) (a_lt_b : a < b) (hx : x ∈ [[a,b]])
    : 0 < x :=  lt_of_lt_of_le apos (uIcc_of_le a_lt_b.le ▸ hx).1

lemma ZetaSum_aux1_2 {a b : ℝ} {c : ℝ} (apos : 0 < a) (a_lt_b : a < b)
    (h : c ≠ 0 ∧ 0 ∉ [[a, b]]) :
    ∫ (x : ℝ) in a..b, 1 / x ^ (c+1) = (a ^ (-c) - b ^ (-c)) / c := by
  rw [(by ring : (a ^ (-c) - b ^ (-c)) / c = (b ^ (-c) - a ^ (-c)) / (-c))]
  have := integral_rpow (a := a) (b := b) (r := -c-1) (Or.inr ⟨by simp [h.1], h.2⟩)
  simp only [sub_add_cancel] at this
  rw [← this]
  apply intervalIntegral.integral_congr
  intro x hx
  have : 0 ≤ x := (ZetaSum_aux1_1 apos a_lt_b hx).le
  simp [div_rpow_eq_rpow_neg _ _ _ this, sub_eq_add_neg, add_comm]

lemma ZetaSum_aux1_3a (x : ℝ) : -(1/2) < ⌊ x ⌋ + 1/2 - x := by
  norm_num [← add_assoc]; linarith [sub_pos_of_lt (Int.lt_floor_add_one x)]

lemma ZetaSum_aux1_3b (x : ℝ) : ⌊x⌋ + 1/2 - x ≤ 1/2 := by
  ring_nf; exact add_le_of_nonpos_right <| sub_nonpos.mpr (Int.floor_le x)

lemma ZetaSum_aux1_3 (x : ℝ) : |(⌊x⌋ + 1/2 - x)| ≤ 1/2 :=
  abs_le.mpr ⟨le_of_lt (ZetaSum_aux1_3a x), ZetaSum_aux1_3b x⟩

lemma ZetaSum_aux1_4' (x : ℝ) (hx : 0 < x) (s : ℂ) :
      ‖(⌊x⌋ + 1 / 2 - (x : ℝ)) / (x : ℂ) ^ (s + 1)‖ =
      |⌊x⌋ + 1 / 2 - x| / x ^ ((s + 1).re) := by
  simp [map_div₀, abs_ofReal, Complex.abs_cpow_eq_rpow_re_of_pos hx, ← abs_ofReal]

lemma ZetaSum_aux1_4 {a b : ℝ} (apos : 0 < a) (a_lt_b : a < b) {s : ℂ} :
  ∫ (x : ℝ) in a..b, ‖(↑⌊x⌋ + (1 : ℝ) / 2 - ↑x) / (x : ℂ) ^ (s + 1)‖ =
    ∫ (x : ℝ) in a..b, |⌊x⌋ + 1 / 2 - x| / x ^ (s + 1).re := by
  apply intervalIntegral.integral_congr
  exact fun x hx ↦ ZetaSum_aux1_4' x (ZetaSum_aux1_1 apos a_lt_b hx) s

lemma ZetaSum_aux1_5a {a b : ℝ} (apos : 0 < a) {s : ℂ} (x : ℝ)
  (h : x ∈ Icc a b) : |↑⌊x⌋ + 1 / 2 - x| / x ^ (s.re + 1) ≤ 1 / x ^ (s.re + 1) := by
  apply div_le_div_of_nonneg_right _ _
  · exact le_trans (ZetaSum_aux1_3 x) (by norm_num)
  · apply Real.rpow_nonneg <| le_of_lt (ZetaSum_aux1_1' apos h)

lemma ZetaSum_aux1_5b {a b : ℝ} (apos : 0 < a) (a_lt_b : a < b) {s : ℂ} (σpos : 0 < s.re) :
  IntervalIntegrable (fun u ↦ 1 / u ^ (s.re + 1)) MeasureTheory.volume a b := by
  apply ContinuousOn.intervalIntegrable_of_Icc (le_of_lt a_lt_b) _
  apply ContinuousOn.div continuousOn_const
  · refine ContinuousOn.rpow_const continuousOn_id ?_
    exact fun x hx ↦ Or.inl (ne_of_gt <| ZetaSum_aux1_1' apos hx)
  · exact fun x hx h ↦ by rw [Real.rpow_eq_zero] at h <;> linarith [ZetaSum_aux1_1' apos hx]

lemma ZetaSum_aux1_5c {a b : ℝ} {s : ℂ} :
    let g : ℝ → ℝ := fun u ↦ |↑⌊u⌋ + 1 / 2 - u| / u ^ (s.re + 1);
    MeasureTheory.AEStronglyMeasurable g
      (MeasureTheory.Measure.restrict MeasureTheory.volume (Ι a b)) := by
  intro
  refine (Measurable.div ?_ <| measurable_id.pow_const _).aestronglyMeasurable
  refine (_root_.continuous_abs).measurable.comp ?_
  refine Measurable.sub (Measurable.add ?_ measurable_const) measurable_id
  exact Measurable.comp (by exact fun _ _ ↦ trivial) Int.measurable_floor

lemma ZetaSum_aux1_5d {a b : ℝ} (apos : 0 < a) (a_lt_b : a < b) {s : ℂ} (σpos : 0 < s.re) :
  IntervalIntegrable (fun u ↦ |↑⌊u⌋ + 1 / 2 - u| / u ^ (s.re + 1)) MeasureTheory.volume a b := by
  set g : ℝ → ℝ := (fun u ↦ |↑⌊u⌋ + 1 / 2 - u| / u ^ (s.re + 1))
  apply IntervalIntegrable.mono_fun (ZetaSum_aux1_5b apos a_lt_b σpos) ZetaSum_aux1_5c ?_
  filter_upwards with x
  simp only [g, Real.norm_eq_abs, one_div, norm_inv, abs_div, _root_.abs_abs]
  conv => rw [div_eq_mul_inv, ← one_div]; rhs; rw [← one_mul |x ^ (s.re + 1)|⁻¹]
  refine mul_le_mul ?_ (le_refl _) (by simp) <| by norm_num
  exact le_trans (ZetaSum_aux1_3 x) <| by norm_num

lemma ZetaSum_aux1_5 {a b : ℝ} (apos : 0 < a) (a_lt_b : a < b) {s : ℂ} (σpos : 0 < s.re) :
  ∫ (x : ℝ) in a..b, |⌊x⌋ + 1 / 2 - x| / x ^ (s.re + 1) ≤ ∫ (x : ℝ) in a..b, 1 / x ^ (s.re + 1) := by
  apply intervalIntegral.integral_mono_on (le_of_lt a_lt_b) ?_ ?_
  · exact ZetaSum_aux1_5a apos
  · exact ZetaSum_aux1_5d apos a_lt_b σpos
  · exact ZetaSum_aux1_5b apos a_lt_b σpos

/-%%
\begin{lemma}[ZetaSum_aux1a]\label{ZetaSum_aux1a}\lean{ZetaSum_aux1a}\leanok
For any $0 < a < b$ and  $s \in \C$ with $\sigma=\Re(s)>0$,
$$
\left|\int_a^b \frac{\lfloor x\rfloor + 1/2 - x}{x^{s+1}} \, dx\right|
\le \frac{a^{-\sigma}-b^{-\sigma}}{\sigma}.
$$
\end{lemma}
%%-/
lemma ZetaSum_aux1a {a b : ℝ} (apos : 0 < a) (a_lt_b : a < b) {s : ℂ} (σpos : 0 < s.re) :
    ‖∫ x in a..b, (⌊x⌋ + 1 / 2 - x) / (x : ℂ) ^ (s + 1)‖ ≤
      (a ^ (-s.re) - b ^ (-s.re)) / s.re := by
  calc
    _ ≤ ∫ x in a..b, ‖(⌊x⌋ + 1 / 2 - x) / (x : ℂ) ^ (s + 1)‖ := ?_
    _ = ∫ x in a..b, |(⌊x⌋ + 1 / 2 - x)| / x ^ (s+1).re := ZetaSum_aux1_4 apos a_lt_b
    _ ≤ ∫ x in a..b, 1 / x ^ (s.re + 1) := ZetaSum_aux1_5 apos a_lt_b σpos
    _ = (a ^ (-s.re) - b ^ (-s.re)) / s.re := ?_
  · exact intervalIntegral.norm_integral_le_integral_norm (μ := MeasureTheory.volume)
      (a := a) (b := b) (f := fun x ↦ (⌊x⌋ + 1 / 2 - x) / (x : ℂ) ^ (s + 1)) (le_of_lt a_lt_b)
  · refine ZetaSum_aux1_2 (c := s.re) apos a_lt_b ⟨ne_of_gt σpos, ?_⟩
    exact fun h ↦ (lt_self_iff_false 0).mp <| ZetaSum_aux1_1 apos a_lt_b h
/-%%
\begin{proof}\leanok
Apply the triangle inequality
$$
\left|\int_a^b \frac{\lfloor x\rfloor + 1/2 - x}{x^{s+1}} \, dx\right|
\le \int_a^b \frac{1}{x^{\sigma+1}} \, dx,
$$
and evaluate the integral.
\end{proof}
%%-/

-- no longer used
lemma tsum_eq_partial_add_tail {N : ℕ} (f : ℕ → ℂ) (hf : Summable f) :
    ∑' (n : ℕ), f n = (∑ n in Finset.Ico 0 N, f n) + ∑' (n : ℕ), f (n + N) := by
  rw [← sum_add_tsum_nat_add (f := f) (h := hf) (k := N), Finset.range_eq_Ico]

lemma finsetSum_tendsto_tsum {N : ℕ} {f : ℕ → ℂ} (hf : Summable f) :
    Tendsto (fun (k : ℕ) ↦ ∑ n in Finset.Ioc N k, f n) atTop (𝓝 (∑' (n : ℕ), f (n + N))) := by
  have := (@Summable.hasSum_iff_tendsto_nat (f := fun m ↦ f (m + N))
     (m := ∑' (n : ℕ), f (n + N)) _ _ _ ?_).mp ?_
  · convert this using 2
    rename ℕ => M
    simp_rw [Finset.range_eq_Ico]
    sorry
  swap; apply (Summable.hasSum_iff ?_).mpr; rfl
  all_goals
  sorry

lemma tendsto_coe_atTop : Tendsto (fun (n : ℕ) ↦ (n : ℝ)) atTop atTop := by
  rw [Filter.tendsto_atTop_atTop]
  intro b
  use ⌊b⌋.toNat + 1
  intro a ha
  by_cases a_zero : a = 0
  · simp [a_zero] at ha
  · by_cases h : ⌊b⌋.toNat < a
    · exact (Int.floor_lt.mp <| (Int.toNat_lt' a_zero).mp h).le
    · simp only [not_lt] at h
      absurd le_trans ha h
      simp

-- related to `ArithmeticFunction.LSeriesSummable_zeta_iff.mpr s_re_gt`
lemma Summable_rpow {s : ℂ} (s_re_gt : 1 < s.re) : Summable (fun (n : ℕ) ↦ 1 / (n : ℂ) ^ s) := by
  apply Summable.of_norm
  have : s.re ≠ 0 := by linarith
  simp only [one_div, norm_inv]
  simp_rw [norm_natCast_cpow_of_re_ne_zero _ this]
  exact (Real.summable_nat_rpow_inv (p := s.re)).mpr s_re_gt

lemma Finset_coe_Nat_Int (f : ℤ → ℂ) (m n : ℕ) :
    (∑ x in Finset.Ioc m n, f x) = ∑ x in Finset.Ioc (m : ℤ) n, f x := by
/-
instead use `Finset.sum_map` and a version of `Nat.image_cast_int_Ioc` stated using `Finset.map`
-/
  apply Finset.sum_nbij (i := (fun (x : ℕ) ↦ (x : ℤ)))
  · intro x hx
    simp only [Finset.mem_Ioc, Nat.cast_lt, Nat.cast_le] at hx ⊢
    exact hx
  · intro x₁ _ x₂ _ h
    simp only [Nat.cast_inj] at h
    exact h
  · intro x hx
    simp only [Finset.coe_Ioc, mem_image, mem_Ioc] at hx ⊢
    have : 0 ≤ x := by linarith
    lift x to ℕ using this
    exact ⟨x, by exact_mod_cast hx, rfl⟩
  · exact fun _ _ ↦ rfl

lemma Complex.cpow_tendsto {s : ℂ} (s_re_gt : 1 < s.re) :
    Tendsto (fun (x : ℕ) ↦ (x : ℂ) ^ (1 - s)) atTop (𝓝 0) := by
  have one_sub_s_re_ne : (1 - s).re ≠ 0 := by simp only [sub_re, one_re]; linarith
  rw [tendsto_zero_iff_norm_tendsto_zero]
  simp_rw [Complex.norm_natCast_cpow_of_re_ne_zero _ (one_sub_s_re_ne)]
  rw [(by simp only [sub_re, one_re, neg_sub] : (1 - s).re = - (s - 1).re)]
  apply (tendsto_rpow_neg_atTop _).comp tendsto_nat_cast_atTop_atTop; simp [s_re_gt]

lemma Complex.cpow_inv_tendsto {s : ℂ} (hs : 0 < s.re) :
    Tendsto (fun (x : ℕ) ↦ ((x : ℂ) ^ s)⁻¹) atTop (𝓝 0) := by
  rw [tendsto_zero_iff_norm_tendsto_zero]
  simp_rw [norm_inv, Complex.norm_natCast_cpow_of_re_ne_zero _ <| ne_of_gt hs]
  apply Filter.Tendsto.inv_tendsto_atTop
  exact (tendsto_rpow_atTop hs).comp tendsto_nat_cast_atTop_atTop

lemma ZetaSum_aux2a : ∃ C, ∀ (x : ℝ), |⌊x⌋ + 1 / 2 - x| ≤ C := by
  use 1 / 2
  intro x
  rcases abs_cases (⌊x⌋ + 1 / 2 - x) with ⟨h₁, _⟩ | ⟨h₁, _⟩ <;> rw [h₁]
  · linarith [Int.floor_le x]
  · linarith [Int.lt_floor_add_one x]

/-%%
\begin{lemma}[ZetaSum_aux2]\label{ZetaSum_aux2}\lean{ZetaSum_aux2}\leanok
  Let $N$ be a natural number and $s\in \C$, $\Re(s)>1$.
  Then
  \[
  \sum_{N < n} \frac{1}{n^s} =  \frac{- N^{1-s}}{1-s} + \frac{-N^{-s}}{2} + s \int_N^\infty \frac{\lfloor x\rfloor + 1/2 - x}{x^{s+1}} \, dx.
  \]
\end{lemma}
%%-/
lemma ZetaSum_aux2 {N : ℕ} (N_pos : 0 < N) {s : ℂ} (s_re_gt : 1 < s.re) :
    ∑' (n : ℕ), 1 / (n + N : ℂ) ^ s =
    (- N ^ (1 - s)) / (1 - s) - N ^ (-s) / 2
      + s * ∫ x in Ioi (N : ℝ), (⌊x⌋ + 1 / 2 - x) * (x : ℂ) ^ (-(s + 1)) := by
  have s_ne_zero : s ≠ 0 := fun hs ↦ by linarith [zero_re ▸ hs ▸ s_re_gt]
  have s_ne_one : s ≠ 1 := fun hs ↦ (lt_self_iff_false _).mp <| one_re ▸ hs ▸ s_re_gt
  apply tendsto_nhds_unique (X := ℂ) (Y := ℕ) (l := atTop)
    (f := fun k ↦ ((k : ℂ) ^ (1 - s) - (N : ℂ) ^ (1 - s)) / (1 - s) + 1 / 2 * (1 / ↑k ^ s) - 1 / 2 * (1 / ↑N ^ s)
      + s * ∫ (x : ℝ) in (N : ℝ)..k, (⌊x⌋ + 1 / 2 - x) * (x : ℂ) ^ (-(s + 1)))
    (b := (- N ^ (1 - s)) / (1 - s) - N ^ (-s) / 2
      + s * ∫ x in Ioi (N : ℝ), (⌊x⌋ + 1 / 2 - x) * (x : ℂ) ^ (-(s + 1)))
  · apply Filter.Tendsto.congr' (f₁ := fun (k : ℕ) ↦ ∑ n in Finset.Ioc N k, 1 / (n : ℂ) ^ s) (l₁ := atTop)
    · apply Filter.eventually_atTop.mpr
      use N + 1
      intro k hk
      convert ZetaSum_aux1 (a := N) (b := k) s_ne_one s_ne_zero ⟨N_pos, hk⟩ using 1
      convert Finset_coe_Nat_Int (fun n ↦ 1 / (n : ℂ) ^ s) N k
    · convert finsetSum_tendsto_tsum (f := fun n ↦ 1 / (n : ℂ) ^ s) (Summable_rpow s_re_gt); simp
  · apply (Tendsto.sub ?_ ?_).add (Tendsto.const_mul _ ?_)
    · rw [(by ring : -↑N ^ (1 - s) / (1 - s) = (0 - ↑N ^ (1 - s)) / (1 - s) + 0)]
      apply cpow_tendsto s_re_gt |>.sub_const _ |>.div_const _ |>.add
      simp_rw [mul_comm_div, one_mul, one_div, (by congr; ring : 𝓝 (0 : ℂ) = 𝓝 ((0 : ℂ) / 2))]
      apply Tendsto.div_const <| cpow_inv_tendsto (by positivity)
    · simp_rw [mul_comm_div, one_mul, one_div, cpow_neg]; exact tendsto_const_nhds
    · refine MeasureTheory.intervalIntegral_tendsto_integral_Ioi (a := N)
        (b := (fun (n : ℕ) ↦ (n : ℝ))) ?_ tendsto_coe_atTop
      apply MeasureTheory.Integrable.bdd_mul ?_ ?_
      · convert ZetaSum_aux2a; simp [← Complex.abs_ofReal]
      · apply integrableOn_Ioi_cpow_iff (by positivity) |>.mpr (by simp [s_re_gt]; positivity)
      · sorry
/-%%
\begin{proof}\uses{ZetaSum_aux1}
  Apply Lemma \ref{ZetaSum_aux1} with $a=N$ and $b\to \infty$.
\end{proof}
%%-/

/-%%
\begin{lemma}[ZetaBnd_aux1]\label{ZetaBnd_aux1}\lean{ZetaBnd_aux1}\leanok
For any $N\ge1$ and $s\in \C$, $\sigma=\Re(s)\in(0,2]$,
$$
\left| s\int_N^\infty \frac{\lfloor x\rfloor + 1/2 - x}{x^{s+1}} \, dx \right|
\ll |t| \frac{N^{-\sigma}}{\sigma},
$$
as $|t|\to\infty$.
\end{lemma}
%%-/

def ct_aux1 := 31381059610 -- 3 ^ 22 + 1
def C_aux1 := 100

lemma ZetaBnd_aux1 (N : ℕ) (Npos : 1 ≤ N) {σ : ℝ} (hσ : σ ∈ Ioc 0 2) :
    ∀ (t : ℝ) (ht : ct_aux1 < |t|),
    ‖(σ + t * I) * ∫ x in Ioi (N : ℝ), (⌊x⌋ + 1 / 2 - x) / (x : ℂ) ^ ((σ + t * I) + 1)‖
    ≤ C_aux1 * |t| * N ^ (-σ) / σ := by
  have := @ZetaSum_aux1a (a := N)
  sorry
/-%%
\begin{proof}\uses{ZetaSum_aux1a}
Apply Lemma \ref{ZetaSum_aux1a} with $a=N$ and $b\to \infty$, and estimate $|s|\ll |t|$.
\end{proof}
%%-/


/-%%
\begin{lemma}[HolomorphicOn_Zeta0]\label{HolomorphicOn_Zeta0}\lean{HolomorphicOn_Zeta0}\leanok
For any $N\ge1$, the function $\zeta_0(N,s)$ is holomorphic on $\{s\in \C\mid \Re(s)>0\}$.
\end{lemma}
%%-/
lemma HolomorphicOn_riemannZeta0 {N : ℕ} (N_pos : 0 < N) :
    HolomorphicOn (ζ₀ N) {s : ℂ | s ≠ 1 ∧ 0 < s.re} := by
  sorry
/-%%
\begin{proof}\uses{ZetaSum_aux1}
  The function $\zeta_0(N,s)$ is a finite sum of entire functions, plus an integral
  that's absolutely convergent on $\{s\in \C\mid \Re(s)>0 ∧ s \ne 1\}$ by Lemma \ref{ZetaSum_aux1}.
%%-/

-- MOVE TO MATHLIB near `differentiableAt_riemannZeta`
lemma HolomophicOn_riemannZeta :
    HolomorphicOn ζ {s : ℂ | s ≠ 1} := by
  intro z hz
  simp only [mem_setOf_eq] at hz
  exact (differentiableAt_riemannZeta hz).differentiableWithinAt


/-%%
\begin{lemma}[isPathConnected_aux]\label{isPathConnected_aux}\lean{isPathConnected_aux}\leanok
The set $\{s\in \C\mid \Re(s)>0 ∧ s \ne 1\}$ is path-connected.
\end{lemma}
%%-/
lemma isPathConnected_aux : IsPathConnected {z : ℂ | z ≠ 1 ∧ 0 < z.re} := by
  use (2 : ℂ)
  constructor; simp
  intro y hy; simp only [ne_eq, mem_setOf_eq] at hy
  by_cases h : y.re ≤ 1
  · apply JoinedIn.trans (y := I)
    · sorry
    · sorry
  · let f : ℝ → ℂ := fun t ↦ y * t + 2 * (1 - t)
    have cont : Continuous f := by continuity
    apply JoinedIn.ofLine cont.continuousOn (by simp [f]) (by simp [f])
    simp [f, unitInterval]
    intro x hx; simp only [mem_Icc] at hx
    simp only [mem_setOf_eq]
    constructor
    · suffices ¬ (2 - y) * x = 1 by
        convert this using 1
        ring_nf
        sorry
      simp [Complex.ext_iff]
      contrapose!
      intro hxy
      rcases hxy with (hx1 | hy1)
      · have hyre: 2 - y.re < 1 := by linarith
        by_cases hx2 : x = 0
        · simp only [hx2]; linarith
        · have := mul_lt_mul (a := 2 - y.re) (b := x) (c := 1) (d := 1) hyre hx.2
            (lt_of_le_of_ne hx.1 <| ((Ne.def _ _).symm ▸ hx2).symm) (by norm_num)
          linarith
      · simp [hy1]
    · sorry
/-%%
\begin{proof}
  Construct explicit paths from $2$ to any point, either a line segment or two joined ones.
%%-/


/-%%
\begin{lemma}[Zeta0EqZeta]\label{Zeta0EqZeta}\lean{Zeta0EqZeta}\leanok
For $\Re(s)>0$, $s\ne1$, and for any $N$,
$$
\zeta_0(N,s) = \zeta(s).
$$
\end{lemma}
%%-/
lemma Zeta0EqZeta {N : ℕ} (N_pos : 0 < N) {s : ℂ} (reS_pos : 0 < s.re) (s_ne_one : s ≠ 1) :
    ζ₀ N s = riemannZeta s := by
  let f := riemannZeta
  let g := ζ₀ N
  let U := {z : ℂ | z ≠ 1 ∧ 0 < z.re}
  have U_open : IsOpen U := by
    refine IsOpen.inter isOpen_ne ?_
    exact isOpen_lt (g := fun (z : ℂ) ↦ z.re) (by continuity) (by continuity)
  have f_an : AnalyticOn ℂ f U := by
    apply (HolomophicOn_riemannZeta.analyticOn isOpen_ne).mono
    simp only [ne_eq, setOf_subset_setOf, and_imp, U]
    exact fun a ha _ ↦ ha
  have g_an : AnalyticOn ℂ g U := (HolomorphicOn_riemannZeta0 N_pos).analyticOn U_open
  have preconU : IsPreconnected U := by
    apply IsConnected.isPreconnected
    apply (IsOpen.isConnected_iff_isPathConnected U_open).mp isPathConnected_aux
  have h2 : (2 : ℂ) ∈ U := by simp [U]
  have s_mem : s ∈ U := by simp [U, reS_pos, s_ne_one]
  convert (AnalyticOn.eqOn_of_preconnected_of_eventuallyEq f_an g_an preconU h2 ?_ s_mem).symm
  have u_mem : {z : ℂ | 1 < z.re} ∈ 𝓝 (2 : ℂ) := by
    apply mem_nhds_iff.mpr
    use {z : ℂ | 1 < z.re}
    simp only [setOf_subset_setOf, imp_self, forall_const, mem_setOf_eq, re_ofNat,
      Nat.one_lt_ofNat, and_true, true_and]
    exact isOpen_lt (by continuity) (by continuity)
  filter_upwards [u_mem]
  intro z hz
  simp only [f,g, zeta_eq_tsum_one_div_nat_cpow hz, riemannZeta0_apply]
  nth_rewrite 2 [neg_div]
  rw [← sub_eq_add_neg, ← ZetaSum_aux2 N_pos hz, ← sum_add_tsum_nat_add N (Summable_rpow hz)]
  congr
  simp
/-%%
\begin{proof}\leanok
\uses{ZetaSum_aux2, RiemannZeta0, HolomorphicOn_Zeta0, isPathConnected_aux}
Use Lemma \ref{ZetaSum_aux2} and the Definition \ref{RiemannZeta0}.
\end{proof}
%%-/

/-%%
\begin{lemma}[ZetaBnd_aux2]\label{ZetaBnd_aux2}\lean{ZetaBnd_aux2}\leanok
Given $n ≤ t$ and $\sigma$ with $1-A/\log t \le \sigma$, we have
that
$$
|n^{-s}| \le n^{-1} e^A.
$$
\end{lemma}
%%-/
lemma ZetaBnd_aux2 {n : ℕ} {t A σ : ℝ} (Apos : 0 < A) (σpos : 0 < σ) (n_le_t : n ≤ |t|)
    (σ_ge : (1 : ℝ) - A / |t|.log ≤ σ) :
    ‖(n : ℂ) ^ (-(σ + t * I))‖ ≤ (n : ℝ)⁻¹ * Real.exp A := by
  set s := σ + t * I
  by_cases n0 : n = 0
  · simp_rw [n0, CharP.cast_eq_zero, inv_zero, zero_mul]
    rw [Complex.zero_cpow ?_]; simp
    exact fun h ↦ (NeZero.of_pos σpos).ne <| zero_eq_neg.mp <| zero_re ▸ h ▸ (by simp [s])
  have n_gt_0 : 0 < n := Nat.pos_of_ne_zero n0
  have n_gt_0' : (0 : ℝ) < (n : ℝ) := Nat.cast_pos.mpr n_gt_0
  have n_ge_1 : 1 ≤ (n : ℝ) := Nat.one_le_cast.mpr <| Nat.succ_le_of_lt n_gt_0
  calc
    _ = |((n : ℝ) ^ (-σ))| := ?_
    _ ≤ Real.exp (Real.log n * -σ) := Real.abs_rpow_le_exp_log_mul (n : ℝ) (-σ)
    _ ≤ Real.exp (Real.log n *  -(1 - A / Real.log t)) := ?_
    _ ≤ Real.exp (- Real.log n + A) := Real.exp_le_exp_of_le ?_
    _ ≤ _ := by rw [Real.exp_add, Real.exp_neg, Real.exp_log n_gt_0']
  · have : ‖(n : ℂ) ^ (-s)‖ = n ^ (-s.re) := abs_cpow_eq_rpow_re_of_pos n_gt_0' (-s)
    rw [this, abs_eq_self.mpr <| Real.rpow_nonneg n_gt_0'.le _]; simp [s]
  · apply Real.exp_le_exp_of_le <| mul_le_mul_of_nonneg_left _ <| Real.log_nonneg n_ge_1
    rw [neg_sub, neg_le_sub_iff_le_add, add_comm, ← Real.log_abs]; linarith
  · simp only [neg_sub, le_neg_add_iff_add_le]
    ring_nf
    conv => rw [mul_comm, ← mul_assoc, ← Real.log_abs]; rhs; rw [← one_mul A]
    gcongr
    by_cases ht1 : |t| = 1; simp [ht1]
    apply (inv_mul_le_iff ?_).mpr; convert Real.log_le_log n_gt_0' n_le_t using 1; rw [mul_one]
    exact Real.log_pos <| lt_of_le_of_ne (le_trans n_ge_1 n_le_t) <| fun t ↦ ht1 (t.symm)
/-%%
\begin{proof}\leanok
Use $|n^{-s}| = n^{-\sigma}
= e^{-\sigma \log n}
\le
\exp(-\left(1-\frac{A}{\log t}\right)\log n)
\le
n^{-1} e^A$,
since $n\le t$.
\end{proof}
%%-/

lemma UpperBnd_aux {A σ t: ℝ} (A_pos : 0 < A) (A_lt : A < 1) (t_ge : 3 < |t|)
      (σ_ge : 1 - A / Real.log |t| ≤ σ) :
      1 < Real.log |t| ∧ 1 - A < σ ∧ 0 < σ ∧ σ + t * I ≠ 1:= by
  have logt_gt_one: 1 < Real.log |t| := by
    rw [← Real.log_exp (x := 1)]
    apply Real.log_lt_log (Real.exp_pos _)
    linarith [(by exact lt_trans Real.exp_one_lt_d9 (by norm_num) : Real.exp 1 < 3)]
  have σ_gt : 1 - A < σ := by
    apply lt_of_lt_of_le ((sub_lt_sub_iff_left (a := 1)).mpr ?_) σ_ge
    exact (div_lt_iff (by linarith)).mpr <| lt_mul_right A_pos logt_gt_one
  refine ⟨logt_gt_one, σ_gt, by linarith, ?__⟩
  contrapose! t_ge
  simp only [Complex.ext_iff, add_re, ofReal_re, mul_re, I_re, mul_zero, ofReal_im, I_im, mul_one,
    sub_self, add_zero, one_re, add_im, mul_im, zero_add, one_im] at t_ge
  norm_num [t_ge.2]

lemma UpperBnd_aux2 {A σ t: ℝ} (A_pos : 0 < A) (A_lt : A < 1) (t_ge : 3 < |t|)
      (σ_ge : 1 - A / |t|.log ≤ σ) :
      |t| ^ (1 - σ) ≤ A.exp := by
  have : |t| ^ (1 - σ) ≤ |t| ^ (A / |t|.log) :=
    Real.rpow_le_rpow_of_exponent_le (by linarith) (by linarith)
  apply le_trans this ?_
  conv => lhs; lhs; rw [← Real.exp_log (by linarith : 0 < |t|)]
  rw [div_eq_mul_inv, Real.rpow_mul (by positivity), ← Real.exp_mul, ← Real.exp_mul, mul_comm,
    ← mul_assoc, inv_mul_cancel, one_mul]
  apply Real.log_ne_zero.mpr; split_ands <;> linarith

lemma riemannZeta0_zero_aux (N : ℕ) (Npos : 0 < N):
    ∑ x in Finset.Ico 0 N, ((x : ℝ))⁻¹ = ∑ x in Finset.Ico 1 N, ((x : ℝ))⁻¹ := by
  have : Finset.Ico 1 N ⊆ Finset.Ico 0 N := by
    intro x hx
    simp only [Finset.mem_Ico, Nat.Ico_zero_eq_range, Finset.mem_range] at hx ⊢
    exact hx.2
  rw [← Finset.sum_sdiff (s₁ := Finset.Ico 1 N) (s₂ := Finset.Ico 0 N) this]
  have : Finset.Ico 0 N \ Finset.Ico 1 N = Finset.range 1 := by
    ext a
    simp only [Nat.Ico_zero_eq_range, Finset.mem_sdiff, Finset.mem_range, Finset.mem_Ico, not_and,
      not_lt, Finset.range_one, Finset.mem_singleton]
    constructor
    · intro ⟨ha₁, ha₂⟩; omega
    · intro ha
      constructor
      · simp [ha, Npos]
      · omega
  rw [this]; simp

lemma UpperBnd_aux3 {A C σ t : ℝ} (Apos : 0 < A) (A_lt_one : A < 1) {N : ℕ} (Npos : 0 < N)
    (σ_ge : 1 - A / Real.log |t| ≤ σ) (t_ge : 3 < |t|) (N_le_t : (N : ℝ) ≤ |t|) (hC : 2 ≤ C) :
     ‖∑ n in Finset.range N, (n : ℂ) ^ (-(σ + t * I))‖ ≤ A.exp * C * |t|.log := by
  obtain ⟨logt_gt_one, _, σPos, _⟩ := UpperBnd_aux Apos A_lt_one t_ge σ_ge
  have (n : ℕ) (hn : n ∈ Finset.range N) := ZetaBnd_aux2 (n := n) Apos σPos ?_ σ_ge
  swap; exact le_trans (Nat.cast_le.mpr (Finset.mem_range.mp hn).le) N_le_t
  replace := norm_sum_le_of_le (Finset.range N) this
  rw [← Finset.sum_mul, mul_comm _ A.exp] at this
  rw [mul_assoc]
  apply le_trans this <| (mul_le_mul_left A.exp_pos).mpr ?_
  have : 1 + (N - 1: ℝ).log ≤ C * |t|.log := by
    by_cases hN : N = 1
    · simp only [hN, Nat.cast_one, sub_self, Real.log_zero, add_zero];
      rw [← mul_one 1]; exact mul_le_mul (by linarith) logt_gt_one.le (by norm_num) (by positivity)
    · rw [(by ring : C * Real.log |t| = (C - 1) * Real.log |t| + Real.log |t|)]
      replace hN : 0 < (N : ℝ) - 1 := by simp only [sub_pos, Nat.one_lt_cast]; omega
      have : (N - 1: ℝ).log ≤ |t|.log := Real.log_le_log hN (by linarith)
      apply add_le_add ?_ this
      nth_rewrite 1 [← mul_one 1]
      exact mul_le_mul (by linarith) logt_gt_one.le (by norm_num) (by linarith)
  refine le_trans ?_ this
  convert harmonic_eq_sum_Icc ▸ harmonic_le_one_add_log (N - 1)
  · simp only [Rat.cast_sum, Rat.cast_inv, Rat.cast_natCast, Finset.range_eq_Ico]
    rw [riemannZeta0_zero_aux N Npos]; congr! 1
  · rw [Nat.cast_pred Npos]

lemma Nat.self_div_floor_bound {t : ℝ}  (t_ge : 1 ≤ |t|) : (|t| / ↑⌊|t|⌋₊) ∈ Icc 1 2 := by
  set N := ⌊|t|⌋₊
  have Npos : 0 < N := Nat.floor_pos.mpr (by linarith)
  have N_le_t : N ≤ |t| := by exact Nat.floor_le <| abs_nonneg _
  constructor
  · apply le_div_iff (by simp [Npos]) |>.mpr; simp [N_le_t]
  · apply div_le_iff (by positivity) |>.mpr
    suffices |t| < ↑N + 1 by linarith [(by exact_mod_cast (by omega) : 1 ≤ (N : ℝ))]
    apply Nat.lt_floor_add_one

lemma le_trans₄ {α : Type*} [Preorder α] {a b c d: α} : a ≤ b → b ≤ c → c ≤ d → a ≤ d :=
  fun hab hbc hcd ↦ le_trans (le_trans hab hbc) hcd

lemma UpperBnd_aux5 {σ t : ℝ}  (t_ge : 3 < |t|) (σ_le : σ ≤ 2) : (|t| / ⌊|t|⌋₊) ^ σ ≤ 4 := by
  obtain ⟨h₁, h₂⟩ := Nat.self_div_floor_bound (by linarith)
  refine le_trans₄ (c := 2 ^ 2) ?_ (Real.rpow_le_rpow (by linarith) h₂ (by norm_num)) (by norm_num)
  exact (Real.rpow_le_rpow_of_exponent_le h₁ σ_le)

lemma UpperBnd_aux6 {σ t : ℝ} (t_ge : 3 < |t|) (σ_gt : 1 / 2 < σ) (σ_le : σ ≤ 2)
  (neOne : σ + t * I ≠ 1) (Npos : 0 < ⌊|t|⌋₊) (N_le_t : ⌊|t|⌋₊ ≤ |t|) :
    ⌊|t|⌋₊ ^ (1 - σ) / ‖1 - (σ + t * I)‖ ≤ |t| ^ (1 - σ) * 2 ∧
    ⌊|t|⌋₊ ^ (-σ) / 2 ≤ |t| ^ (1 - σ) ∧ ⌊|t|⌋₊ ^ (-σ) / σ ≤ 8 * |t| ^ (-σ) := by
  have bnd := UpperBnd_aux5 t_ge σ_le
  have bnd' : (|t| / ⌊|t|⌋₊) ^ σ ≤ 2 * |t| := by linarith
  split_ands
  · apply (div_le_iff <| norm_pos_iff.mpr <| sub_ne_zero_of_ne neOne.symm).mpr
    conv => rw [mul_assoc]; rhs; rw [mul_comm]
    apply (div_le_iff <| Real.rpow_pos_of_pos (by linarith) _).mp
    rw [div_rpow_eq_rpow_div_neg (by positivity) (by positivity), neg_sub]
    refine le_trans₄ ?_ bnd' ?_
    · exact Real.rpow_le_rpow_of_exponent_le (one_le_div (by positivity) |>.mpr N_le_t) (by simp)
    · apply (mul_le_mul_left (by norm_num)).mpr; simpa using abs_im_le_abs (1 - (σ + t * I))
  · apply div_le_iff (by norm_num) |>.mpr
    rw [Real.rpow_sub (by linarith), Real.rpow_one, div_mul_eq_mul_div, mul_comm]
    apply div_le_iff (by positivity) |>.mp
    convert bnd' using 1
    rw [← Real.rpow_neg (by linarith), div_rpow_neg_eq_rpow_div (by positivity) (by positivity)]
  · apply div_le_iff (by positivity) |>.mpr
    rw [mul_assoc, mul_comm, mul_assoc]
    apply div_le_iff' (by positivity) |>.mp
    apply le_trans ?_ (by linarith : 4 ≤ σ * 8)
    convert bnd using 1; exact div_rpow_neg_eq_rpow_div (by positivity) (by positivity)

lemma norm_add₄_le {E: Type*} [SeminormedAddGroup E] (a : E) (b : E) (c : E) (d : E) :
    ‖a + b + c + d‖ ≤ ‖a‖ + ‖b‖ + ‖c‖ + ‖d‖ := by
  apply le_trans <| norm_add_le (a + b + c) d
  simp only [add_le_add_iff_right]; apply norm_add₃_le

lemma add_le_add_le_add {α : Type*} [Add α] [Preorder α]
    [CovariantClass α α (fun x x_1 ↦ x + x_1) fun x x_1 ↦ x ≤ x_1]
    [CovariantClass α α (Function.swap fun x x_1 ↦ x + x_1) fun x x_1 ↦ x ≤ x_1]
    {a b c d e f : α} (h₁ : a ≤ b) (h₂ : c ≤ d) (h₃ : e ≤ f) : a + c + e ≤ b + d + f :=
  add_le_add (add_le_add h₁ h₂) h₃

lemma add_le_add_le_add_le_add {α : Type*} [Add α] [Preorder α]
    [CovariantClass α α (fun x x_1 ↦ x + x_1) fun x x_1 ↦ x ≤ x_1]
    [CovariantClass α α (Function.swap fun x x_1 ↦ x + x_1) fun x x_1 ↦ x ≤ x_1]
    {a b c d e f g h : α} (h₁ : a ≤ b) (h₂ : c ≤ d) (h₃ : e ≤ f) (h₄ : g ≤ h) :
    a + c + e + g ≤ b + d + f + h:= add_le_add (add_le_add_le_add h₁ h₂ h₃) h₄

/-%%
\begin{lemma}[ZetaUpperBnd]\label{ZetaUpperBnd}\lean{ZetaUpperBnd}\leanok
For any $s\in \C$, $1/2 \le \Re(s)=\sigma\le 2$,
and any $0 < A < 1$ sufficiently small, and $1-A/\log |t| \le \sigma$, we have
$$
|\zeta(s)| \ll \log t,
$$
as $|t|\to\infty$.
\end{lemma}
%%-/
lemma ZetaUpperBnd :
    ∃ (A : ℝ) (Apos : 0 < A) (C : ℝ) (Cpos : 0 < C), ∀ (σ : ℝ) (t : ℝ) (t_ge : ct_aux1 < |t|)
    (_ : σ ∈ Icc (1 - A / |t|.log) 2), ‖ζ (σ + t * I)‖ ≤ C * |t|.log := by
  let A := (1 : ℝ) / 2
  have Apos : 0 < A := by norm_num
  let C := A.exp * (5 + 8 * C_aux1)
  refine ⟨A, Apos, C, (by positivity), ?_⟩
  intro σ t t_ge ⟨σ_ge, σ_le⟩
  have t_ge' : 3 < |t| := lt_trans (by norm_num [ct_aux1]) t_ge
  set N := ⌊|t|⌋₊
  have Npos : 0 < N := Nat.floor_pos.mpr (by linarith)
  have N_le_t : N ≤ |t| := Nat.floor_le <| abs_nonneg _
  obtain ⟨logt_gt_one, σ_gt, σPos, neOne⟩ := UpperBnd_aux Apos (by norm_num) t_ge' σ_ge
  norm_num [A] at σ_gt
  rw [← Zeta0EqZeta (N := N) Npos (by simp [σPos]) neOne]
  set s := σ + t * I
  calc
    _ ≤ ‖∑ n in Finset.range N, 1 / (n : ℂ) ^ s‖ + ‖(- N ^ (1 - s)) / (1 - s)‖ +
      ‖(-(N : ℂ) ^ (-s)) / 2‖ +
      ‖s * ∫ x in Ioi (N : ℝ), (⌊x⌋ + 1 / 2 - x) / (x : ℂ) ^ (s + 1)‖ := by apply norm_add₄_le
    _ ≤ A.exp * 2 * |t|.log + ‖(- N ^ (1 - s)) / (1 - s)‖ + ‖(-(N : ℂ) ^ (-s)) / 2‖ +
      ‖s * ∫ x in Ioi (N : ℝ), (⌊x⌋ + 1 / 2 - x) / (x : ℂ) ^ (s + 1)‖ := ?_
    _ ≤ A.exp * 2 * |t|.log + ‖(- N ^ (1 - s)) / (1 - s)‖ + ‖(-(N : ℂ) ^ (-s)) / 2‖ +
      C_aux1 * |t| * N ^ (-σ) / σ  := ?_
    _ = A.exp * 2 * |t|.log + N ^ (1 - σ) / ‖(1 - s)‖ + N ^ (-σ) / 2 +
      C_aux1 * |t| * N ^ (-σ) / σ  := ?_
    _ ≤ A.exp * 2 * |t|.log + |t| ^ (1 - σ) * 2 +
        |t| ^ (1 - σ) + C_aux1 * |t| * (8 * |t| ^ (-σ)) := ?_
    _ = A.exp * 2 * |t|.log + (3 + 8 * C_aux1) * |t| ^ (1 - σ) := ?_
    _ ≤ A.exp * 2 * |t|.log + (3 + 8 * C_aux1) * A.exp * 1 := ?_
    _ ≤ A.exp * 2 * |t|.log + (3 + 8 * C_aux1) * A.exp * |t|.log:= ?_
    _ = _ := by ring
  · simp only [add_le_add_iff_right, one_div_cpow_eq_cpow_neg]
    convert UpperBnd_aux3 (C := 2) Apos (by norm_num) Npos σ_ge t_ge' N_le_t le_rfl
  · simp only [add_le_add_iff_left]; exact ZetaBnd_aux1 N (by linarith) ⟨σPos, σ_le⟩ t t_ge
  · simp only [norm_div, norm_neg, norm_eq_abs, RCLike.norm_ofNat, Nat.abs_cast, s]
    congr <;> (convert norm_natCast_cpow_of_pos Npos _; simp)
  · have ⟨h₁, h₂, h₃⟩ := UpperBnd_aux6 t_ge' σ_gt σ_le neOne Npos N_le_t
    refine add_le_add_le_add_le_add le_rfl h₁ h₂ ?_
    rw [mul_div_assoc]
    exact mul_le_mul_left (mul_pos (by norm_num [C_aux1]) (by positivity)) |>.mpr h₃
  · ring_nf; conv => lhs; rhs; lhs; rw [mul_assoc, mul_comm |t|]
    rw [← Real.rpow_add_one (by positivity)]; ring_nf
  · simp only [Real.log_abs, add_le_add_iff_left, mul_one]
    exact mul_le_mul_left (by positivity) |>.mpr <| UpperBnd_aux2 Apos (by norm_num) t_ge' σ_ge
  · simp only [add_le_add_iff_left]
    apply mul_le_mul_left (by norm_num [Real.exp_pos, C_aux1]) |>.mpr <| logt_gt_one.le
/-%%
\begin{proof}\uses{ZetaBnd_aux1, ZetaBnd_aux2, Zeta0EqZeta}\leanok
First replace $\zeta(s)$ by $\zeta_0(N,s)$ for $N = \lfloor |t| \rfloor$.
We estimate:
$$
|\zeta_0(N,s)| \ll
\sum_{1\le n < |t|} |n^{-s}|
+
\frac{- |t|^{1-\sigma}}{|1-s|} + \frac{-|t|^{-\sigma}}{2} +
|t| \cdot |t| ^ (-σ) / σ
$$
$$
\ll
e^A \sum_{1\le n < |t|} n^{-1}
+|t|^{1-\sigma}
$$
,
where we used Lemma \ref{ZetaBnd_aux2} and Lemma \ref{ZetaBnd_aux1}.
The first term is $\ll \log |t|$.
For the second term, estimate
$$
|t|^{1-\sigma}
\le |t|^{1-(1-A/\log |t|)}
= |t|^{A/\log |t|} \ll 1.
$$
\end{proof}
%%-/

/-%%
\begin{lemma}[ZetaDerivUpperBnd]\label{ZetaDerivUpperBnd}\lean{ZetaDerivUpperBnd}\leanok
For any $s\in \C$, $1/2 \le \Re(s)=\sigma\le 2$,
there is an $A>0$ so that for $1-A/\log t \le \sigma$, we have
$$
|\zeta'(s)| \ll \log^2 t,
$$
as $|t|\to\infty$.
\end{lemma}
%%-/
lemma ZetaDerivUpperBnd :
    ∃ (A : ℝ) (Apos : 0 < A) (C : ℝ) (Cpos : 0 < C), ∀ (σ : ℝ) (t : ℝ) (t_gt : 3 < |t|)
    (hσ : σ ∈ Icc (1 - A / Real.log |t|) 2),
    ‖deriv ζ (σ + t * I)‖ ≤ C * (Real.log |t|) ^ 2 := by
  let A := (1 : ℝ) / 2
  have Apos : 0 < A := by norm_num
  refine ⟨A, Apos, 10, by norm_num, ?_⟩
  intro σ t t_ge ⟨σ_ge, σ_le⟩
  set N := ⌊|t|⌋₊
  set s := σ + t * I
  obtain ⟨logt_gt_one, σ_gt, σPos, neOne⟩ := UpperBnd_aux Apos (by norm_num) t_ge σ_ge
  have : deriv ζ s = deriv (ζ₀ N) s := by
    have := Zeta0EqZeta (N := N) (Nat.floor_pos.mpr (by linarith)) (by simp [σPos]) neOne
    -- these functions agree on an open set, their derivatives agree there too
    sorry
  rw [this]
  -- use calc similar to the one for ZetaUpperBnd
  sorry
/-%%
\begin{proof}\uses{ZetaBnd_aux1, ZetaBnd_aux2, Zeta0EqZeta}
First replace $\zeta(s)$ by $\zeta_0(N,s)$ for $N = \lfloor |t| \rfloor$.
Differentiating term by term, we get:
$$
\zeta'(s) = -\sum_{1\le n < N} n^{-s} \log n
-
\frac{N^{1 - s}}{1 - s)^2} + \frac{N^{1 - s} \log N} {1 - s}
+ \frac{-N^{-s}\log N}{2} +
\int_N^\infty \frac{\lfloor x\rfloor + 1/2 - x}{x^{s+1}} \, dx
-
s(s+1) \int_N^\infty \frac{\lfloor x\rfloor + 1/2 - x}{x^{s+2}} \, dx
.
$$
Estimate as before, with an extra factor of $\log |t|$.
\end{proof}
%%-/

lemma Tendsto_nhdsWithin_punctured_map_add {f : ℝ → ℝ} (a x : ℝ)
    (f_mono : StrictMono f) (f_iso : Isometry f):
    Tendsto (fun y ↦ f y + a) (𝓝[>] x) (𝓝[>] (f x + a)) := by
  refine tendsto_iff_forall_eventually_mem.mpr ?_
  intro v hv
  simp only [mem_nhdsWithin] at hv
  obtain ⟨u, hu, hu2, hu3⟩ := hv
  let t := {x | f x + a ∈ u}
  have : t ∩ Ioi x ∈ 𝓝[>] x := by
    simp only [mem_nhdsWithin]
    use t
    simp only [subset_inter_iff, inter_subset_left, inter_subset_right, and_self,
      and_true, t]
    simp
    refine ⟨?_, by simp [hu2]⟩
    simp [Metric.isOpen_iff] at hu ⊢
    intro x hx
    obtain ⟨ε, εpos, hε⟩ := hu (f x + a) hx
    simp only [Metric.ball, dist_sub_eq_dist_add_right, setOf_subset_setOf] at hε ⊢
    exact ⟨ε, εpos, fun _ hy ↦ hε (by simp [isometry_iff_dist_eq.mp f_iso, hy])⟩
  filter_upwards [this]
  intro b hb
  simp only [mem_inter_iff, mem_setOf_eq, mem_Ioi, t] at hb
  refine hu3 ?_
  simp only [mem_inter_iff, mem_Ioi, add_lt_add_iff_right]
  exact ⟨hb.1, f_mono hb.2⟩

lemma Tendsto_nhdsWithin_punctured_add (a x : ℝ) :
    Tendsto (fun y ↦ y + a) (𝓝[>] x) (𝓝[>] (x + a)) :=
  Tendsto_nhdsWithin_punctured_map_add a x strictMono_id isometry_id

/-%%
\begin{lemma}[ZetaNear1BndFilter]\label{ZetaNear1BndFilter}\lean{ZetaNear1BndFilter}\leanok
As $\sigma\to1^+$,
$$
|\zeta(\sigma)| \ll 1/(\sigma-1).
$$
\end{lemma}
%%-/
lemma ZetaNear1BndFilter:
    (fun σ : ℝ ↦ ζ σ) =O[𝓝[>](1 : ℝ)] (fun σ ↦ (1 : ℂ) / (σ - 1)) := by
  have := Tendsto_nhdsWithin_punctured_add (a := -1) (x := 1)
  simp only [add_right_neg, ← sub_eq_add_neg] at this
  have := riemannZeta_isBigO_near_one_horizontal.comp_tendsto this
  convert this using 1 <;> {ext; simp}
/-%%
\begin{proof}\uses{ZetaBnd_aux1, Zeta0EqZeta}\leanok
Zeta has a simple pole at $s=1$. Equivalently, $\zeta(s)(s-1)$ remains bounded near $1$.
Lots of ways to prove this.
Probably the easiest one: use the expression for $\zeta_0 (N,s)$ with $N=1$ (the term $N^{1-s}/(1-s)$ being the only unbounded one).
\end{proof}
%%-/

/-%%
\begin{lemma}[ZetaNear1BndExact]\label{ZetaNear1BndExact}\lean{ZetaNear1BndExact}\leanok
There exists a $c>0$ such that for all $1 < \sigma ≤ 2$,
$$
|\zeta(\sigma)| ≤ c/(\sigma-1).
$$
\end{lemma}
%%-/
lemma ZetaNear1BndExact:
    ∃ (c : ℝ) (cpos : 0 < c), ∀ (σ : ℝ) (_ : σ ∈ Ioc 1 2), ‖ζ σ‖ ≤ c / (σ - 1) := by
  have := ZetaNear1BndFilter
  rw [Asymptotics.isBigO_iff] at this
  obtain ⟨c, U, hU, V, hV, h⟩ := this
  obtain ⟨T, hT, T_open, h1T⟩ := mem_nhds_iff.mp hU
  obtain ⟨ε, εpos, hε⟩ := Metric.isOpen_iff.mp T_open 1 h1T
  simp only [Metric.ball] at hε
  replace hε : Ico 1 (1 + ε) ⊆ U := by
    refine subset_trans (subset_trans ?_ hε) hT
    intro x hx
    simp only [mem_Ico] at hx
    simp only [dist, abs_lt]
    exact ⟨by linarith, by linarith⟩
  let W := Icc (1 + ε) 2
  have W_compact : IsCompact {ofReal' z | z ∈ W} :=
    IsCompact.image isCompact_Icc continuous_ofReal
  have cont : ContinuousOn ζ {ofReal' z | z ∈ W} := by
    apply HasDerivAt.continuousOn (f' := deriv ζ)
    intro σ hσ
    exact (differentiableAt_riemannZeta (by contrapose! hσ; simp [W, hσ, εpos])).hasDerivAt
  obtain ⟨C, hC⟩ := IsCompact.exists_bound_of_continuousOn W_compact cont
  let C' := max (C + 1) 1
  replace hC : ∀ (σ : ℝ), σ ∈ W → ‖ζ σ‖ < C' := by
    intro σ hσ
    simp only [lt_max_iff, C']
    have := hC σ
    simp only [mem_setOf_eq, ofReal_inj, exists_eq_right] at this
    exact Or.inl <| lt_of_le_of_lt (this hσ) (by norm_num)
  have Cpos : 0 < C' := by simp [C']
  use max (2 * C') c, (by simp [Cpos])
  intro σ ⟨σ_ge, σ_le⟩
  by_cases hσ : σ ∈ U ∩ V
  · simp only [← h, mem_setOf_eq] at hσ
    apply le_trans hσ ?_
    norm_cast
    have : 0 ≤ 1 / (σ - 1) := by apply one_div_nonneg.mpr; linarith
    simp only [norm_eq_abs, Complex.abs_ofReal, abs_eq_self.mpr this, mul_div, mul_one]
    exact div_le_div (by simp [Cpos.le]) (by simp) (by linarith) (by rfl)
  · replace hσ : σ ∈ W := by
      simp only [mem_inter_iff, hV σ_ge, and_true] at hσ
      simp only [mem_Icc, σ_le, and_true, W]
      contrapose! hσ; exact hε ⟨σ_ge.le, hσ⟩
    apply le_trans (hC σ hσ).le ((le_div_iff (by linarith)).mpr ?_)
    rw [le_max_iff, mul_comm 2]; exact Or.inl <| mul_le_mul_of_nonneg_left (by linarith) Cpos.le
/-%%
\begin{proof}\uses{ZetaNear1BndFilter}\leanok
Split into two cases, use Lemma \ref{ZetaNear1BndFilter} for $\sigma$ sufficiently small
and continuity on a compact interval otherwise.
\end{proof}
%%-/

/-%%
\begin{lemma}[ZetaInvBound1]\label{ZetaInvBound1}\lean{ZetaInvBound1}\leanok
For all $\sigma>1$,
$$
1/|\zeta(\sigma+it)| \le |\zeta(\sigma)|^{3/4}|\zeta(\sigma+2it)|^{1/4}
$$
\end{lemma}
%%-/
lemma ZetaInvBound1 {σ t : ℝ} (σ_gt : 1 < σ) :
    1 / ‖ζ (σ + t * I)‖ ≤ ‖ζ σ‖ ^ ((3 : ℝ) / 4) * ‖ζ (σ + 2 * t * I)‖ ^ ((1 : ℝ) / 4) := by
  apply (div_le_iff ?_).mpr
  apply (Real.rpow_le_rpow_iff (z := 4) (by norm_num) ?_ (by norm_num)).mp
  · simp only [Real.one_rpow]
    rw [Real.mul_rpow, Real.mul_rpow, ← Real.rpow_mul, ← Real.rpow_mul]
    simp only [isUnit_iff_ne_zero, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true,
      IsUnit.div_mul_cancel, IsUnit.inv_mul_cancel, Real.rpow_one]
    conv => rw [mul_assoc]; rhs; rhs; rw [mul_comm]
    rw [← mul_assoc]
    have := norm_zeta_product_ge_one (x := σ - 1) (by linarith) t
    simp_rw [ge_iff_le, norm_mul, norm_pow, ofReal_sub, ofReal_one, add_sub_cancel, ← Real.rpow_nat_cast] at this
    convert this using 3 <;> ring_nf
    any_goals ring_nf
    any_goals apply norm_nonneg
    any_goals apply Real.rpow_nonneg <| norm_nonneg _
    apply mul_nonneg <;> apply Real.rpow_nonneg <| norm_nonneg _
  · refine mul_nonneg (mul_nonneg ?_ ?_) ?_ <;> simp [Real.rpow_nonneg]
  · have s_ne_one : σ + t * I ≠ 1 := by
      contrapose! σ_gt; apply le_of_eq; apply And.left; simpa [Complex.ext_iff] using σ_gt
    have zeta_ne_zero:= riemannZeta_ne_zero_of_one_le_re s_ne_one (by simp [σ_gt.le])
    suffices 0 ≤ ‖ζ (↑σ + ↑t * I)‖ by simp [le_iff_lt_or_eq.mp this, zeta_ne_zero]
    apply norm_nonneg
/-%%
\begin{proof}\leanok
The identity
$$
1 \le |\zeta(\sigma)|^3 |\zeta(\sigma+it)|^4 |\zeta(\sigma+2it)|
$$
for $\sigma>1$
is already proved by Michael Stoll in the EulerProducts PNT file.
\end{proof}
%%-/

lemma Ioi_union_Iio_mem_cocompact {a : ℝ} (ha : 0 ≤ a) : Ioi (a : ℝ) ∪ Iio (-a : ℝ) ∈ cocompact ℝ := by
  simp only [Filter.mem_cocompact]
  use Icc (-a) a
  constructor
  · exact isCompact_Icc
  · rw [@compl_subset_iff_union, ← union_assoc, Icc_union_Ioi_eq_Ici, union_comm, Iio_union_Ici]
    linarith

lemma lt_abs_mem_cocompact {a : ℝ} (ha : 0 ≤ a) : {t | a < |t|} ∈ cocompact ℝ := by
  convert Ioi_union_Iio_mem_cocompact ha using 1; ext t
  simp only [mem_setOf_eq, mem_union, mem_Ioi, mem_Iio, lt_abs, lt_neg]

/-%%
\begin{lemma}[ZetaInvBound2]\label{ZetaInvBound2}\lean{ZetaInvBound2}\leanok
For $\sigma>1$ (and $\sigma \le 2$),
$$
1/|\zeta(\sigma+it)| \ll (\sigma-1)^{-3/4}(\log |t|)^{1/4},
$$
as $|t|\to\infty$.
\end{lemma}
%%-/
lemma ZetaInvBound2 {σ : ℝ} (hσ : σ ∈ Ioc 1 2) :
    (fun (t : ℝ) ↦ 1 / ‖ζ (σ + t * I)‖) =O[cocompact ℝ]
      fun (t : ℝ) ↦ (σ - 1) ^ (-(3 : ℝ) / 4) * (Real.log |t|) ^ ((1 : ℝ) / 4) := by
  obtain ⟨A, ha, C, hC, h⟩ := ZetaUpperBnd
  obtain ⟨c, hc, h_inv⟩ := ZetaNear1BndExact
  obtain ⟨σ_gt, σ_le⟩ := hσ
  rw [Asymptotics.isBigO_iff]
  use (2 * C) ^ ((1 : ℝ)/ 4) * c ^ ((3 : ℝ)/ 4)
  filter_upwards [lt_abs_mem_cocompact (by norm_num [ct_aux1] : 0 ≤ (ct_aux1 : ℝ) / 2)] with t ht
  have ht' : ct_aux1 < |2 * t| := by
    convert div_lt_iff' (by positivity) |>.mp ht using 1; simp [abs_mul]
  norm_num [ct_aux1] at ht ht'
  have hnezero: ((σ - 1) / c) ^ (-3 / 4 : ℝ) ≠ 0 := by
    have : (σ - 1) / c ≠ 0 := ne_of_gt <| div_pos (by linarith) hc
    contrapose! this
    rwa [Real.rpow_eq_zero (div_nonneg (by linarith) hc.le) (by norm_num)] at this
  calc
    _ ≤ ‖‖ζ σ‖ ^ (3 / 4 : ℝ) * ‖ζ (↑σ + 2 * ↑t * I)‖ ^ (1 / 4 : ℝ)‖ := ?_
    _ ≤ ‖((σ - 1) / c) ^ (-3 / 4 : ℝ) * ‖ζ (↑σ + 2 * ↑t * I)‖ ^ (1 / 4 : ℝ)‖ := ?_
    _ ≤ ‖((σ - 1) / c) ^ (-3 / 4 : ℝ) * C ^ (1 / 4 : ℝ) * (Real.log |2 * t|) ^ (1 / 4 : ℝ)‖ := ?_
    _ ≤ ‖((σ - 1) / c) ^ (-3 / 4 : ℝ) * C ^ (1 / 4 : ℝ) * (Real.log (|t| ^ 2)) ^ (1 / 4 : ℝ)‖ := ?_
    _ = ‖((σ - 1)) ^ (-3 / 4 : ℝ) * c ^ (3 / 4 : ℝ) * (C ^ (1 / 4 : ℝ) * (Real.log (|t| ^ 2)) ^ (1 / 4 : ℝ))‖ := ?_
    _ = ‖((σ - 1)) ^ (-3 / 4 : ℝ) * c ^ (3 / 4 : ℝ) * ((2 * C) ^ (1 / 4 : ℝ) * Real.log |t| ^ (1 / 4 : ℝ))‖ := ?_
    _ = _ := ?_
  · simp only [norm_div, norm_one, norm_mul, norm_norm]
    convert ZetaInvBound1 σ_gt using 2
    <;> exact abs_eq_self.mpr <| Real.rpow_nonneg (apply_nonneg _ _) _
  · have bnd1: ‖ζ σ‖ ^ (3 / 4 : ℝ) ≤ ((σ - 1) / c) ^ (-(3 : ℝ) / 4) := by
      have : ((σ - 1) / c) ^ (-(3 : ℝ) / 4) = (((σ - 1) / c) ^ (-1 : ℝ)) ^ (3 / 4 : ℝ) := by
        rw [← Real.rpow_mul ?_]; ring_nf; exact div_nonneg (by linarith) hc.le
      rw [this]
      apply Real.rpow_le_rpow (by simp [apply_nonneg]) ?_ (by norm_num)
      convert h_inv σ ⟨σ_gt, σ_le⟩ using 1; simp [Real.rpow_neg_one, inv_div]
    simp only [norm_div, norm_one, norm_mul]
    apply (mul_le_mul_right ?_).mpr
    convert bnd1 using 1
    · exact abs_eq_self.mpr <| Real.rpow_nonneg (apply_nonneg _ _) _
    · exact abs_eq_self.mpr <| Real.rpow_nonneg (div_nonneg (by linarith) hc.le) _
    · apply lt_iff_le_and_ne.mpr ⟨(by simp), ?_⟩
      have : ζ (↑σ + 2 * ↑t * I) ≠ 0 := by
        apply riemannZeta_ne_zero_of_one_le_re ?_ (by simp [σ_gt.le])
        contrapose! σ_gt; apply le_of_eq; apply And.left; simpa [Complex.ext_iff] using σ_gt
      symm; exact fun h2 ↦ this (by simpa using h2)
  · replace h := h σ (2 * t) (by simp [ct_aux1, ht']) ⟨?_, σ_le⟩
    · have : 0 ≤ Real.log |2 * t| := Real.log_nonneg (by linarith)
      conv => rhs; rw [mul_assoc, ← Real.mul_rpow hC.le this]
      rw [norm_mul, norm_mul]
      conv => rhs; rhs; rw [Real.norm_rpow_of_nonneg <| mul_nonneg hC.le this]
      conv => lhs; rhs; rw [Real.norm_rpow_of_nonneg <| norm_nonneg _]
      apply (mul_le_mul_left ?_).mpr
      apply Real.rpow_le_rpow (norm_nonneg _) ?_ (by norm_num)
      · convert h using 1; simp
        rw [Real.norm_eq_abs, abs_eq_self.mpr <| mul_nonneg hC.le this]
      · simpa only [Real.norm_eq_abs, abs_pos]
    · linarith [(div_nonneg ha.le (Real.log_nonneg (by linarith)) : 0 ≤ A / Real.log |2 * t|)]
  · simp only [Real.log_abs, norm_mul]
    apply (mul_le_mul_left ?_).mpr
    · rw [← Real.log_abs, Real.norm_rpow_of_nonneg <| Real.log_nonneg (by linarith)]
      have : 1 ≤ |(|t| ^ 2)| := by
        simp only [_root_.sq_abs, _root_.abs_pow, one_le_sq_iff_one_le_abs]
        linarith
      conv => rhs; rw [← Real.log_abs, Real.norm_rpow_of_nonneg <| Real.log_nonneg this]
      apply Real.rpow_le_rpow (abs_nonneg _) ?_ (by norm_num)
      · rw [Real.norm_eq_abs, abs_eq_self.mpr <| Real.log_nonneg (by linarith)]
        rw [abs_eq_self.mpr <| Real.log_nonneg this, abs_mul, Real.log_abs, Nat.abs_ofNat]
        apply Real.log_le_log (mul_pos (by norm_num) (by linarith)) (by nlinarith)
    . apply mul_pos (abs_pos.mpr hnezero) (abs_pos.mpr ?_)
      have : C ≠ 0 := ne_of_gt hC
      contrapose! this; rwa [Real.rpow_eq_zero (by linarith) (by norm_num)] at this
  · have : (-3 : ℝ) / 4 = -((3 : ℝ)/ 4) := by norm_num
    simp only [norm_mul, mul_eq_mul_right_iff, abs_eq_zero, this, ← mul_assoc]; left; left
    conv => lhs; rw [Real.div_rpow (by linarith) hc.le, Real.rpow_neg hc.le, div_inv_eq_mul, norm_mul]
  · simp only [Real.log_pow, Nat.cast_ofNat, norm_mul, Real.norm_eq_abs]
    congr! 1
    rw [Real.mul_rpow (by norm_num) hC.le, Real.mul_rpow (by norm_num) <|
        Real.log_nonneg (by linarith), abs_mul, abs_mul, ← mul_assoc, mul_comm _ |2 ^ (1 / 4)|]
  · simp only [norm_mul, Real.norm_eq_abs]
    have : (2 * C) ^ ((1 : ℝ)/ 4) * c ^ ((3 : ℝ)/ 4) =|(2 * C) ^ ((1 : ℝ)/ 4) * c ^ ((3 : ℝ)/ 4)| := by
      rw [abs_eq_self.mpr (by apply mul_nonneg <;> (apply Real.rpow_nonneg; linarith))]
    rw [this, abs_mul]; ring
/-%%
\begin{proof}\uses{ZetaInvBound1, ZetaNear1BndExact, ZetaUpperBnd}\leanok
Combine Lemma \ref{ZetaInvBound1} with the bounds in Lemmata \ref{ZetaNear1BndExact} and
\ref{ZetaUpperBnd}.
\end{proof}
%%-/

lemma deriv_fun_re {t : ℝ} {f : ℂ → ℂ} (diff : ∀ (σ : ℝ), DifferentiableAt ℂ f (↑σ + ↑t * I)) :
    (deriv fun {σ₂ : ℝ} ↦ f (σ₂ + t * I)) = fun (σ : ℝ) ↦ deriv f (σ + t * I) := by
  ext σ
  have := deriv.comp (h := fun (σ : ℝ) ↦ σ + t * I) (h₂ := f) σ (diff σ) ?_
  · simp only [deriv_add_const', _root_.deriv_ofReal, mul_one] at this
    rw [← this]
    rfl
  · apply DifferentiableAt.add_const <| differentiableAt_ofReal σ

/-%%
\begin{lemma}[Zeta_eq_int_derivZeta]\label{Zeta_eq_int_derivZeta}\lean{Zeta_eq_int_derivZeta}
\leanok
For any $t\ne0$ (so we don't pass through the pole), and $\sigma_1 < \sigma_2$,
$$
\int_{\sigma_1}^{\sigma_2}\zeta'(\sigma + it) dt =
\zeta(\sigma_2+it) - \zeta(\sigma_1+it).
$$
\end{lemma}
%%-/
lemma Zeta_eq_int_derivZeta {σ₁ σ₂ t : ℝ} (t_ne_zero : t ≠ 0) :
    (∫ σ in σ₁..σ₂, deriv ζ (σ + t * I)) = ζ (σ₂ + t * I) - ζ (σ₁ + t * I) := by
  have diff : ∀ (σ : ℝ), DifferentiableAt ℂ ζ (σ + t * I) := by
    intro σ
    refine differentiableAt_riemannZeta ?_
    contrapose! t_ne_zero; apply And.right; simpa [Complex.ext_iff] using t_ne_zero
  apply intervalIntegral.integral_deriv_eq_sub'
  · exact deriv_fun_re diff
  · intro s _
    apply DifferentiableAt.comp
    · exact (diff s).restrictScalars ℝ
    · exact DifferentiableAt.add_const (c := t * I) <| differentiableAt_ofReal _
  · apply ContinuousOn.comp (g := deriv ζ) ?_ ?_ (mapsTo_image _ _)
    · apply HasDerivAt.continuousOn (f' := deriv <| deriv ζ)
      intro x hx
      apply hasDerivAt_deriv_iff.mpr
      replace hx : x ≠ 1 := by
        contrapose! hx
        simp only [hx, mem_image, Complex.ext_iff, add_re, ofReal_re, mul_re, I_re, mul_zero, ofReal_im,
          I_im, mul_one, sub_self, add_zero, one_re, add_im, mul_im, zero_add, one_im, not_exists,
          not_and]
        exact fun _ _ _ ↦ t_ne_zero
      have := (Complex.analyticAt_iff_eventually_differentiableAt (c := x) (f := ζ)).mpr ?_
      · obtain ⟨r, hr, h⟩ := this.exists_ball_analyticOn
        apply (h.deriv x ?_).differentiableAt
        simp [hr]
      · filter_upwards [compl_singleton_mem_nhds hx] with z hz
        apply differentiableAt_riemannZeta
        simpa [mem_compl_iff, mem_singleton_iff] using hz
    · exact ContinuousOn.add continuous_ofReal.continuousOn continuousOn_const
/-%%
\begin{proof}\leanok
This is the fundamental theorem of calculus.
\end{proof}
%%-/

/-%%
\begin{lemma}[Zeta_diff_Bnd]\label{Zeta_diff_Bnd}\lean{Zeta_diff_Bnd}\leanok
For any $A>0$ sufficiently small, there is a constant $C>0$ so that
whenever $1- A / \log t \le \sigma_1 < \sigma_2\le 2$, we have that:
$$
|\zeta (\sigma_2 + it) - \zeta (\sigma_1 + it)|
\le C (\log |t|)^2 (\sigma_2 - \sigma_1).
$$
\end{lemma}
%%-/
lemma Zeta_diff_Bnd :
    ∃ (A : ℝ) (Apos : 0 < A) (C : ℝ) (Cpos : 0 < C), ∀ (σ₁ σ₂ : ℝ) (t : ℝ) (t_gt : 3 < |t|)
    (σ₁_ge : 1 - A / Real.log |t| ≤ σ₁) (σ₂_le : σ₂ ≤ 2) (σ₁_lt_σ₂ : σ₁ < σ₂),
    ‖ζ (σ₂ + t * I) - ζ (σ₁ + t * I)‖ ≤  C * (Real.log |t|) ^ 2 * (σ₂ - σ₁) := by
  obtain ⟨A, Apos, C, Cpos, hC⟩ := ZetaDerivUpperBnd
  refine ⟨A, Apos, C, Cpos, ?_⟩
  intro σ₁ σ₂ t t_gt σ₁_ge σ₂_le σ₁_lt_σ₂
  have t_ne_zero : t ≠ 0 := by contrapose! t_gt; simp only [t_gt, abs_zero, Nat.ofNat_nonneg]
  rw [← Zeta_eq_int_derivZeta t_ne_zero]
  convert intervalIntegral.norm_integral_le_of_norm_le_const ?_ using 1
  · congr; rw [_root_.abs_of_nonneg (by linarith)]
  · intro σ hσ; rw [uIoc_of_le σ₁_lt_σ₂.le, mem_Ioc] at hσ
    exact hC σ t t_gt ⟨le_trans σ₁_ge hσ.1.le, le_trans hσ.2 σ₂_le⟩
/-%%
\begin{proof}
\uses{Zeta_eq_int_derivZeta, ZetaDerivUpperBnd}\leanok
Use Lemma \ref{Zeta_eq_int_derivZeta} and
estimate trivially using Lemma \ref{ZetaDerivUpperBnd}.
\end{proof}
%%-/

/-%%
\begin{lemma}[ZetaInvBnd]\label{ZetaInvBnd}\lean{ZetaInvBnd}\leanok
For any $A>0$ sufficiently small, there is a constant $C>0$ so that
whenever $1- A / \log^9 |t| \le \sigma < 1$, we have that:
$$
1/|\zeta(\sigma+it)| \le C \log^7 |t|.
$$
\end{lemma}
%%-/
lemma ZetaInvBnd :
    ∃ (A : ℝ) (Apos : 0 < A) (C : ℝ) (Cpos : 0 < C), ∀ (σ : ℝ) (t : ℝ) (t_gt : 3 < |t|)
    (hσ : σ ∈ Ico (1 - A / (Real.log |t|) ^ 9) 1),
    1 / ‖ζ (σ + t * I)‖ ≤ C * (Real.log |t|) ^ 7 := by
  sorry
/-%%
\begin{proof}
\uses{Zeta_diff_Bnd, ZetaInvBound2}
Let $\sigma$ be given in the prescribed range, and set $\sigma' := 1+ A / \log^9 |t|$.
Then
$$
|\zeta(\sigma+it)| \ge
|\zeta(\sigma'+it)| - |\zeta(\sigma+it) - \zeta(\sigma'+it)|
\ge
C (\sigma'-1)^{-3/4}\log |t|^{-1/4} - C \log^2 |t| (\sigma'-\sigma)
$$
$$
\ge
C A^{-3/4} \log |t|^{-7} - C \log^2 |t| (2 A / \log^9 |t|),
$$
where we used Lemma \ref{ZetaInvBound2}  and Lemma \ref{Zeta_diff_Bnd}.
Now by making $A$ sufficiently small (in particular, something like $A = 1/16$ should work), we can guarantee that
$$
|\zeta(\sigma+it)| \ge \frac C 2 (\log |t|)^{-7},
$$
as desired.
\end{proof}
%%-/

/-%%
\begin{lemma}[LogDerivZetaBnd]\label{LogDerivZetaBnd}\lean{LogDerivZetaBnd}\leanok
There is an $A>0$ so that for $1-A/\log^9 |t| \le \sigma < 1$,
$$
|\frac {\zeta'}{\zeta} (\sigma+it)| \ll \log^9 |t|.
$$
\end{lemma}
%%-/
lemma LogDerivZetaBnd :
    ∃ (A : ℝ) (Apos : 0 < A) (C : ℝ) (Cpos : 0 < C), ∀ (σ : ℝ) (t : ℝ) (t_gt : 3 < |t|)
    (hσ : σ ∈ Ico (1 - A / (Real.log |t|) ^ 9) 1),
    ‖deriv ζ (σ + t * I) / ζ (σ + t * I)‖ ≤
      C * (Real.log |t|) ^ 9 := by
  obtain ⟨A, hA, C, hC, h⟩ := ZetaInvBnd
  obtain ⟨A', hA', C', hC', h'⟩ := ZetaDerivUpperBnd
  use min A A', lt_min hA hA', C * C', mul_pos hC hC'
  intro σ t t_gt ⟨σ_ge, σ_lt⟩
  have logt_gt : (1 : ℝ) < Real.log |t| := by
    refine (Real.lt_log_iff_exp_lt (by linarith)).mpr (lt_trans ?_ t_gt)
    exact lt_trans Real.exp_one_lt_d9 (by norm_num)
  have σ_ge' : 1 - A / Real.log |t| ^ 9 ≤ σ := by
    apply le_trans (tsub_le_tsub_left ?_ 1) σ_ge
    apply div_le_div hA.le (min_le_left A A') ?_ (by rfl)
    exact pow_pos (lt_trans (by norm_num) logt_gt) 9
  have σ_ge'' : 1 - A' / Real.log |t| ≤ σ := by
    apply le_trans (tsub_le_tsub_left ?_ 1) σ_ge
    apply div_le_div hA'.le (min_le_right A A') (lt_trans (by norm_num) logt_gt) ?_
    exact le_self_pow logt_gt.le (by norm_num)
  replace h := h σ t t_gt ⟨σ_ge', σ_lt⟩
  replace h' := h' σ t t_gt ⟨σ_ge'', by linarith⟩
  simp only [norm_div, norm_one, norm_mul, norm_inv]
  convert mul_le_mul h h' (by simp [apply_nonneg]) ?_ using 1 <;> ring_nf
  exact mul_nonneg hC.le <| pow_nonneg (Real.log_nonneg (by linarith)) 7
/-%%
\begin{proof}\leanok
\uses{ZetaInvBnd, ZetaDerivUpperBnd}
Combine the bound on $|\zeta'|$ from Lemma \ref{ZetaDerivUpperBnd} with the bound on $1/|\zeta|$ from Lemma \ref{ZetaInvBnd}.
\end{proof}
%%-/
