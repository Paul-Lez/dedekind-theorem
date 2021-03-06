/-
Copyright (c) 2020 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth
-/
import analysis.normed_space.hahn_banach
import analysis.normed_space.is_R_or_C

/-!
# The topological dual of a normed space

In this file we define the topological dual `normed_space.dual` of a normed space, and the
continuous linear map `normed_space.inclusion_in_double_dual` from a normed space into its double
dual.

For base field `๐ = โ` or `๐ = โ`, this map is actually an isometric embedding; we provide a
version `normed_space.inclusion_in_double_dual_li` of the map which is of type a bundled linear
isometric embedding, `E โโแตข[๐] (dual ๐ (dual ๐ E))`.

Since a lot of elementary properties don't require `eq_of_dist_eq_zero` we start setting up the
theory for `semi_normed_space` and we specialize to `normed_space` when needed.

## Main definitions

* `inclusion_in_double_dual` and `inclusion_in_double_dual_li` are the inclusion of a normed space
  in its double dual, considered as a bounded linear map and as a linear isometry, respectively.
* `polar ๐ s` is the subset of `dual ๐ E` consisting of those functionals `x'` for which
  `โฅx' zโฅ โค 1` for every `z โ s`.

## Tags

dual
-/

noncomputable theory
open_locale classical
universes u v

namespace normed_space

section general
variables (๐ : Type*) [nondiscrete_normed_field ๐]
variables (E : Type*) [semi_normed_group E] [semi_normed_space ๐ E]
variables (F : Type*) [normed_group F] [normed_space ๐ F]

/-- The topological dual of a seminormed space `E`. -/
@[derive [inhabited, semi_normed_group, semi_normed_space ๐]] def dual := E โL[๐] ๐

instance : add_monoid_hom_class (dual ๐ E) E ๐ := continuous_linear_map.add_monoid_hom_class

instance : has_coe_to_fun (dual ๐ E) (ฮป _, E โ ๐) := continuous_linear_map.to_fun

instance : normed_group (dual ๐ F) := continuous_linear_map.to_normed_group

instance : normed_space ๐ (dual ๐ F) := continuous_linear_map.to_normed_space

instance [finite_dimensional ๐ E] : finite_dimensional ๐ (dual ๐ E) :=
continuous_linear_map.finite_dimensional

/-- The inclusion of a normed space in its double (topological) dual, considered
   as a bounded linear map. -/
def inclusion_in_double_dual : E โL[๐] (dual ๐ (dual ๐ E)) :=
continuous_linear_map.apply ๐ ๐

@[simp] lemma dual_def (x : E) (f : dual ๐ E) : inclusion_in_double_dual ๐ E x f = f x := rfl

lemma inclusion_in_double_dual_norm_eq :
  โฅinclusion_in_double_dual ๐ Eโฅ = โฅ(continuous_linear_map.id ๐ (dual ๐ E))โฅ :=
continuous_linear_map.op_norm_flip _

lemma inclusion_in_double_dual_norm_le : โฅinclusion_in_double_dual ๐ Eโฅ โค 1 :=
by { rw inclusion_in_double_dual_norm_eq, exact continuous_linear_map.norm_id_le }

lemma double_dual_bound (x : E) : โฅ(inclusion_in_double_dual ๐ E) xโฅ โค โฅxโฅ :=
by simpa using continuous_linear_map.le_of_op_norm_le _ (inclusion_in_double_dual_norm_le ๐ E) x

end general

section bidual_isometry

variables (๐ : Type v) [is_R_or_C ๐]
  {E : Type u} [normed_group E] [normed_space ๐ E]

/-- If one controls the norm of every `f x`, then one controls the norm of `x`.
    Compare `continuous_linear_map.op_norm_le_bound`. -/
lemma norm_le_dual_bound (x : E) {M : โ} (hMp: 0 โค M) (hM : โ (f : dual ๐ E), โฅf xโฅ โค M * โฅfโฅ) :
  โฅxโฅ โค M :=
begin
  classical,
  by_cases h : x = 0,
  { simp only [h, hMp, norm_zero] },
  { obtain โจf, hfโฉ : โ g : E โL[๐] ๐, _ := exists_dual_vector ๐ x h,
    calc โฅxโฅ = โฅ(โฅxโฅ : ๐)โฅ : is_R_or_C.norm_coe_norm.symm
    ... = โฅf xโฅ : by rw hf.2
    ... โค M * โฅfโฅ : hM f
    ... = M : by rw [hf.1, mul_one] }
end

lemma eq_zero_of_forall_dual_eq_zero {x : E} (h : โ f : dual ๐ E, f x = (0 : ๐)) : x = 0 :=
norm_eq_zero.mp (le_antisymm (norm_le_dual_bound ๐ x le_rfl (ฮป f, by simp [h f])) (norm_nonneg _))

lemma eq_zero_iff_forall_dual_eq_zero (x : E) : x = 0 โ โ g : dual ๐ E, g x = 0 :=
โจฮป hx, by simp [hx], ฮป h, eq_zero_of_forall_dual_eq_zero ๐ hโฉ

lemma eq_iff_forall_dual_eq {x y : E} :
  x = y โ โ g : dual ๐ E, g x = g y :=
begin
  rw [โ sub_eq_zero, eq_zero_iff_forall_dual_eq_zero ๐ (x - y)],
  simp [sub_eq_zero],
end

/-- The inclusion of a normed space in its double dual is an isometry onto its image.-/
def inclusion_in_double_dual_li : E โโแตข[๐] (dual ๐ (dual ๐ E)) :=
{ norm_map' := begin
    intros x,
    apply le_antisymm,
    { exact double_dual_bound ๐ E x },
    rw continuous_linear_map.norm_def,
    refine le_cInf continuous_linear_map.bounds_nonempty _,
    rintros c โจhc1, hc2โฉ,
    exact norm_le_dual_bound ๐ x hc1 hc2
  end,
  .. inclusion_in_double_dual ๐ E }

end bidual_isometry

end normed_space

section polar_sets

open metric set normed_space

/-- Given a subset `s` in a normed space `E` (over a field `๐`), the polar
`polar ๐ s` is the subset of `dual ๐ E` consisting of those functionals which
evaluate to something of norm at most one at all points `z โ s`. -/
def polar (๐ : Type*) [nondiscrete_normed_field ๐]
  {E : Type*} [normed_group E] [normed_space ๐ E] (s : set E) : set (dual ๐ E) :=
{x' : dual ๐ E | โ z โ s, โฅ x' z โฅ โค 1}

open metric set normed_space
open_locale topological_space

variables (๐ : Type*) [nondiscrete_normed_field ๐]
variables {E : Type*} [normed_group E] [normed_space ๐ E]

@[simp] lemma zero_mem_polar (s : set E) :
  (0 : dual ๐ E) โ polar ๐ s :=
ฮป _ _, by simp only [zero_le_one, continuous_linear_map.zero_apply, norm_zero]

lemma polar_eq_Inter (s : set E) :
  polar ๐ s = โ z โ s, {x' : dual ๐ E | โฅ x' z โฅ โค 1} :=
by { ext, simp only [polar, mem_bInter_iff, mem_set_of_eq], }

@[simp] lemma polar_empty : polar ๐ (โ : set E) = univ :=
by simp only [polar, forall_false_left, mem_empty_eq, forall_const, set_of_true]

variables {๐}

/-- If `x'` is a dual element such that the norms `โฅx' zโฅ` are bounded for `z โ s`, then a
small scalar multiple of `x'` is in `polar ๐ s`. -/
lemma smul_mem_polar {s : set E} {x' : dual ๐ E} {c : ๐}
  (hc : โ z, z โ s โ โฅ x' z โฅ โค โฅcโฅ) : cโปยน โข x' โ polar ๐ s :=
begin
  by_cases c_zero : c = 0, { simp [c_zero] },
  have eq : โ z, โฅ cโปยน โข (x' z) โฅ = โฅ cโปยน โฅ * โฅ x' z โฅ := ฮป z, norm_smul cโปยน _,
  have le : โ z, z โ s โ โฅ cโปยน โข (x' z) โฅ โค โฅ cโปยน โฅ * โฅ c โฅ,
  { intros z hzs,
    rw eq z,
    apply mul_le_mul (le_of_eq rfl) (hc z hzs) (norm_nonneg _) (norm_nonneg _), },
  have cancel : โฅ cโปยน โฅ * โฅ c โฅ = 1,
  by simp only [c_zero, norm_eq_zero, ne.def, not_false_iff,
                inv_mul_cancel, normed_field.norm_inv],
  rwa cancel at le,
end

variables (๐)

/-- The `polar` of closed ball in a normed space `E` is the closed ball of the dual with
inverse radius. -/
lemma polar_closed_ball
  {๐ : Type*} [is_R_or_C ๐] {E : Type*} [normed_group E] [normed_space ๐ E] {r : โ} (hr : 0 < r) :
  polar ๐ (closed_ball (0 : E) r) = closed_ball (0 : dual ๐ E) (1/r) :=
begin
  ext x',
  simp only [mem_closed_ball, mem_set_of_eq, dist_zero_right],
  split,
  { intros h,
    apply continuous_linear_map.op_norm_le_of_ball hr (one_div_nonneg.mpr hr.le),
    { exact ฮป z hz, linear_map.bound_of_ball_bound hr 1 x'.to_linear_map h z, },
    { exact ring_hom_isometric.ids, }, },
  { intros h z hz,
    simp only [mem_closed_ball, dist_zero_right] at hz,
    have key := (continuous_linear_map.le_op_norm x' z).trans
      (mul_le_mul h hz (norm_nonneg _) (one_div_nonneg.mpr hr.le)),
    rwa [one_div_mul_cancel hr.ne.symm] at key, },
end

/-- Given a neighborhood `s` of the origin in a normed space `E`, the dual norms
of all elements of the polar `polar ๐ s` are bounded by a constant. -/
lemma polar_bounded_of_nhds_zero {s : set E} (s_nhd : s โ ๐ (0 : E)) :
  โ (c : โ), โ x' โ polar ๐ s, โฅx'โฅ โค c :=
begin
  obtain โจa, haโฉ : โ a : ๐, 1 < โฅaโฅ := normed_field.exists_one_lt_norm ๐,
  obtain โจr, r_pos, r_ballโฉ : โ (r : โ) (hr : 0 < r), ball 0 r โ s :=
    metric.mem_nhds_iff.1 s_nhd,
  refine โจโฅaโฅ / r, ฮป x' hx', _โฉ,
  have I : 0 โค โฅaโฅ / r := div_nonneg (norm_nonneg _) r_pos.le,
  refine continuous_linear_map.op_norm_le_of_shell r_pos I ha (ฮป x hx h'x, _),
  have x_mem : x โ ball (0 : E) r, by simpa only [mem_ball_zero_iff] using h'x,
  calc โฅx' xโฅ โค 1 : hx' x (r_ball x_mem)
  ... = (โฅaโฅ / r) * (r / โฅaโฅ) : by field_simp [r_pos.ne', (zero_lt_one.trans ha).ne']
  ... โค (โฅaโฅ / r) * โฅxโฅ : mul_le_mul_of_nonneg_left hx I
end

end polar_sets
