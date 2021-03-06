/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov
-/
import analysis.inner_product_space.basic
import analysis.special_functions.sqrt

/-!
# Derivative of the inner product

In this file we prove that the inner product and square of the norm in an inner space are
infinitely `β`-smooth. In order to state these results, we need a `normed_space β E`
instance. Though we can deduce this structure from `inner_product_space π E`, this instance may be
not definitionally equal to some other βnaturalβ instance. So, we assume `[normed_space β E]`.
-/

noncomputable theory

open is_R_or_C real filter
open_locale big_operators classical topological_space

variables {π E F : Type*} [is_R_or_C π]
variables [inner_product_space π E] [inner_product_space β F]
local notation `βͺ`x`, `y`β«` := @inner π _ _ x y

variables [normed_space β E]

/-- Derivative of the inner product. -/
def fderiv_inner_clm (p : E Γ E) : E Γ E βL[β] π := is_bounded_bilinear_map_inner.deriv p

@[simp] lemma fderiv_inner_clm_apply (p x : E Γ E) :
  fderiv_inner_clm  p x = βͺp.1, x.2β« + βͺx.1, p.2β« := rfl

lemma times_cont_diff_inner {n} : times_cont_diff β n (Ξ» p : E Γ E, βͺp.1, p.2β«) :=
is_bounded_bilinear_map_inner.times_cont_diff

lemma times_cont_diff_at_inner {p : E Γ E} {n} :
  times_cont_diff_at β n (Ξ» p : E Γ E, βͺp.1, p.2β«) p :=
times_cont_diff_inner.times_cont_diff_at

lemma differentiable_inner : differentiable β (Ξ» p : E Γ E, βͺp.1, p.2β«) :=
is_bounded_bilinear_map_inner.differentiable_at

variables {G : Type*} [normed_group G] [normed_space β G]
  {f g : G β E} {f' g' : G βL[β] E} {s : set G} {x : G} {n : with_top β}

include π

lemma times_cont_diff_within_at.inner (hf : times_cont_diff_within_at β n f s x)
  (hg : times_cont_diff_within_at β n g s x) :
  times_cont_diff_within_at β n (Ξ» x, βͺf x, g xβ«) s x :=
times_cont_diff_at_inner.comp_times_cont_diff_within_at x (hf.prod hg)

lemma times_cont_diff_at.inner (hf : times_cont_diff_at β n f x)
  (hg : times_cont_diff_at β n g x) :
  times_cont_diff_at β n (Ξ» x, βͺf x, g xβ«) x :=
hf.inner hg

lemma times_cont_diff_on.inner (hf : times_cont_diff_on β n f s) (hg : times_cont_diff_on β n g s) :
  times_cont_diff_on β n (Ξ» x, βͺf x, g xβ«) s :=
Ξ» x hx, (hf x hx).inner (hg x hx)

lemma times_cont_diff.inner (hf : times_cont_diff β n f) (hg : times_cont_diff β n g) :
  times_cont_diff β n (Ξ» x, βͺf x, g xβ«) :=
times_cont_diff_inner.comp (hf.prod hg)

lemma has_fderiv_within_at.inner (hf : has_fderiv_within_at f f' s x)
  (hg : has_fderiv_within_at g g' s x) :
  has_fderiv_within_at (Ξ» t, βͺf t, g tβ«) ((fderiv_inner_clm (f x, g x)).comp $ f'.prod g') s x :=
(is_bounded_bilinear_map_inner.has_fderiv_at (f x, g x)).comp_has_fderiv_within_at x (hf.prod hg)

lemma has_strict_fderiv_at.inner (hf : has_strict_fderiv_at f f' x)
  (hg : has_strict_fderiv_at g g' x) :
  has_strict_fderiv_at (Ξ» t, βͺf t, g tβ«) ((fderiv_inner_clm (f x, g x)).comp $ f'.prod g') x :=
(is_bounded_bilinear_map_inner.has_strict_fderiv_at (f x, g x)).comp x (hf.prod hg)

lemma has_fderiv_at.inner (hf : has_fderiv_at f f' x) (hg : has_fderiv_at g g' x) :
  has_fderiv_at (Ξ» t, βͺf t, g tβ«) ((fderiv_inner_clm (f x, g x)).comp $ f'.prod g') x :=
(is_bounded_bilinear_map_inner.has_fderiv_at (f x, g x)).comp x (hf.prod hg)

lemma has_deriv_within_at.inner {f g : β β E} {f' g' : E} {s : set β} {x : β}
  (hf : has_deriv_within_at f f' s x) (hg : has_deriv_within_at g g' s x) :
  has_deriv_within_at (Ξ» t, βͺf t, g tβ«) (βͺf x, g'β« + βͺf', g xβ«) s x :=
by simpa using (hf.has_fderiv_within_at.inner hg.has_fderiv_within_at).has_deriv_within_at

lemma has_deriv_at.inner {f g : β β E} {f' g' : E} {x : β} :
  has_deriv_at f f' x β  has_deriv_at g g' x β
  has_deriv_at (Ξ» t, βͺf t, g tβ«) (βͺf x, g'β« + βͺf', g xβ«) x :=
by simpa only [β has_deriv_within_at_univ] using has_deriv_within_at.inner

lemma differentiable_within_at.inner (hf : differentiable_within_at β f s x)
  (hg : differentiable_within_at β g s x) :
  differentiable_within_at β (Ξ» x, βͺf x, g xβ«) s x :=
((differentiable_inner _).has_fderiv_at.comp_has_fderiv_within_at x
  (hf.prod hg).has_fderiv_within_at).differentiable_within_at

lemma differentiable_at.inner (hf : differentiable_at β f x) (hg : differentiable_at β g x) :
  differentiable_at β (Ξ» x, βͺf x, g xβ«) x :=
(differentiable_inner _).comp x (hf.prod hg)

lemma differentiable_on.inner (hf : differentiable_on β f s) (hg : differentiable_on β g s) :
  differentiable_on β (Ξ» x, βͺf x, g xβ«) s :=
Ξ» x hx, (hf x hx).inner (hg x hx)

lemma differentiable.inner (hf : differentiable β f) (hg : differentiable β g) :
  differentiable β (Ξ» x, βͺf x, g xβ«) :=
Ξ» x, (hf x).inner (hg x)

lemma fderiv_inner_apply (hf : differentiable_at β f x) (hg : differentiable_at β g x) (y : G) :
  fderiv β (Ξ» t, βͺf t, g tβ«) x y = βͺf x, fderiv β g x yβ« + βͺfderiv β f x y, g xβ« :=
by { rw [(hf.has_fderiv_at.inner hg.has_fderiv_at).fderiv], refl }

lemma deriv_inner_apply {f g : β β E} {x : β} (hf : differentiable_at β f x)
  (hg : differentiable_at β g x) :
  deriv (Ξ» t, βͺf t, g tβ«) x = βͺf x, deriv g xβ« + βͺderiv f x, g xβ« :=
(hf.has_deriv_at.inner hg.has_deriv_at).deriv

lemma times_cont_diff_norm_sq : times_cont_diff β n (Ξ» x : E, β₯xβ₯ ^ 2) :=
begin
  simp only [sq, β inner_self_eq_norm_mul_norm],
  exact (re_clm : π βL[β] β).times_cont_diff.comp (times_cont_diff_id.inner times_cont_diff_id)
end

lemma times_cont_diff.norm_sq (hf : times_cont_diff β n f) :
  times_cont_diff β n (Ξ» x, β₯f xβ₯ ^ 2) :=
times_cont_diff_norm_sq.comp hf

lemma times_cont_diff_within_at.norm_sq (hf : times_cont_diff_within_at β n f s x) :
  times_cont_diff_within_at β n (Ξ» y, β₯f yβ₯ ^ 2) s x :=
times_cont_diff_norm_sq.times_cont_diff_at.comp_times_cont_diff_within_at x hf

lemma times_cont_diff_at.norm_sq (hf : times_cont_diff_at β n f x) :
  times_cont_diff_at β n (Ξ» y, β₯f yβ₯ ^ 2) x :=
hf.norm_sq

lemma times_cont_diff_at_norm {x : E} (hx : x β  0) : times_cont_diff_at β n norm x :=
have β₯id xβ₯ ^ 2 β  0, from pow_ne_zero _ (norm_pos_iff.2 hx).ne',
by simpa only [id, sqrt_sq, norm_nonneg] using times_cont_diff_at_id.norm_sq.sqrt this

lemma times_cont_diff_at.norm (hf : times_cont_diff_at β n f x) (h0 : f x β  0) :
  times_cont_diff_at β n (Ξ» y, β₯f yβ₯) x :=
(times_cont_diff_at_norm h0).comp x hf

lemma times_cont_diff_at.dist (hf : times_cont_diff_at β n f x) (hg : times_cont_diff_at β n g x)
  (hne : f x β  g x) :
  times_cont_diff_at β n (Ξ» y, dist (f y) (g y)) x :=
by { simp only [dist_eq_norm], exact (hf.sub hg).norm (sub_ne_zero.2 hne) }

lemma times_cont_diff_within_at.norm (hf : times_cont_diff_within_at β n f s x) (h0 : f x β  0) :
  times_cont_diff_within_at β n (Ξ» y, β₯f yβ₯) s x :=
(times_cont_diff_at_norm h0).comp_times_cont_diff_within_at x hf

lemma times_cont_diff_within_at.dist (hf : times_cont_diff_within_at β n f s x)
  (hg : times_cont_diff_within_at β n g s x) (hne : f x β  g x) :
  times_cont_diff_within_at β n (Ξ» y, dist (f y) (g y)) s x :=
by { simp only [dist_eq_norm], exact (hf.sub hg).norm (sub_ne_zero.2 hne) }

lemma times_cont_diff_on.norm_sq (hf : times_cont_diff_on β n f s) :
  times_cont_diff_on β n (Ξ» y, β₯f yβ₯ ^ 2) s :=
(Ξ» x hx, (hf x hx).norm_sq)

lemma times_cont_diff_on.norm (hf : times_cont_diff_on β n f s) (h0 : β x β s, f x β  0) :
  times_cont_diff_on β n (Ξ» y, β₯f yβ₯) s :=
Ξ» x hx, (hf x hx).norm (h0 x hx)

lemma times_cont_diff_on.dist (hf : times_cont_diff_on β n f s)
  (hg : times_cont_diff_on β n g s) (hne : β x β s, f x β  g x) :
  times_cont_diff_on β n (Ξ» y, dist (f y) (g y)) s :=
Ξ» x hx, (hf x hx).dist (hg x hx) (hne x hx)

lemma times_cont_diff.norm (hf : times_cont_diff β n f) (h0 : β x, f x β  0) :
  times_cont_diff β n (Ξ» y, β₯f yβ₯) :=
times_cont_diff_iff_times_cont_diff_at.2 $ Ξ» x, hf.times_cont_diff_at.norm (h0 x)

lemma times_cont_diff.dist (hf : times_cont_diff β n f) (hg : times_cont_diff β n g)
  (hne : β x, f x β  g x) :
  times_cont_diff β n (Ξ» y, dist (f y) (g y)) :=
times_cont_diff_iff_times_cont_diff_at.2 $
  Ξ» x, hf.times_cont_diff_at.dist hg.times_cont_diff_at (hne x)

omit π
lemma has_strict_fderiv_at_norm_sq (x : F) :
  has_strict_fderiv_at (Ξ» x, β₯xβ₯ ^ 2) (bit0 (innerSL x)) x :=
begin
  simp only [sq, β inner_self_eq_norm_mul_norm],
  convert (has_strict_fderiv_at_id x).inner (has_strict_fderiv_at_id x),
  ext y,
  simp [bit0, real_inner_comm],
end
include π

lemma differentiable_at.norm_sq (hf : differentiable_at β f x) :
  differentiable_at β (Ξ» y, β₯f yβ₯ ^ 2) x :=
(times_cont_diff_at_id.norm_sq.differentiable_at le_rfl).comp x hf

lemma differentiable_at.norm (hf : differentiable_at β f x) (h0 : f x β  0) :
  differentiable_at β (Ξ» y, β₯f yβ₯) x :=
((times_cont_diff_at_norm h0).differentiable_at le_rfl).comp x hf

lemma differentiable_at.dist (hf : differentiable_at β f x) (hg : differentiable_at β g x)
  (hne : f x β  g x) :
  differentiable_at β (Ξ» y, dist (f y) (g y)) x :=
by { simp only [dist_eq_norm], exact (hf.sub hg).norm (sub_ne_zero.2 hne) }

lemma differentiable.norm_sq (hf : differentiable β f) : differentiable β (Ξ» y, β₯f yβ₯ ^ 2) :=
Ξ» x, (hf x).norm_sq

lemma differentiable.norm (hf : differentiable β f) (h0 : β x, f x β  0) :
  differentiable β (Ξ» y, β₯f yβ₯) :=
Ξ» x, (hf x).norm (h0 x)

lemma differentiable.dist (hf : differentiable β f) (hg : differentiable β g)
  (hne : β x, f x β  g x) :
  differentiable β (Ξ» y, dist (f y) (g y)) :=
Ξ» x, (hf x).dist (hg x) (hne x)

lemma differentiable_within_at.norm_sq (hf : differentiable_within_at β f s x) :
  differentiable_within_at β (Ξ» y, β₯f yβ₯ ^ 2) s x :=
(times_cont_diff_at_id.norm_sq.differentiable_at le_rfl).comp_differentiable_within_at x hf

lemma differentiable_within_at.norm (hf : differentiable_within_at β f s x) (h0 : f x β  0) :
  differentiable_within_at β (Ξ» y, β₯f yβ₯) s x :=
((times_cont_diff_at_id.norm h0).differentiable_at le_rfl).comp_differentiable_within_at x hf

lemma differentiable_within_at.dist (hf : differentiable_within_at β f s x)
  (hg : differentiable_within_at β g s x) (hne : f x β  g x) :
  differentiable_within_at β (Ξ» y, dist (f y) (g y)) s x :=
by { simp only [dist_eq_norm], exact (hf.sub hg).norm (sub_ne_zero.2 hne) }

lemma differentiable_on.norm_sq (hf : differentiable_on β f s) :
  differentiable_on β (Ξ» y, β₯f yβ₯ ^ 2) s :=
Ξ» x hx, (hf x hx).norm_sq

lemma differentiable_on.norm (hf : differentiable_on β f s) (h0 : β x β s, f x β  0) :
  differentiable_on β (Ξ» y, β₯f yβ₯) s :=
Ξ» x hx, (hf x hx).norm (h0 x hx)

lemma differentiable_on.dist (hf : differentiable_on β f s) (hg : differentiable_on β g s)
  (hne : β x β s, f x β  g x) :
  differentiable_on β (Ξ» y, dist (f y) (g y)) s :=
Ξ» x hx, (hf x hx).dist (hg x hx) (hne x hx)
