/-
Copyright (c) 2021 YaÃ«l Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: YaÃ«l Dillies
-/
import analysis.convex.basic
import topology.algebra.mul_action
import topology.algebra.ordered.basic

/-!
# Strictly convex sets

This file defines strictly convex sets.

A set is strictly convex if the open segment between any two distinct points lies in its interior.

## TODO

Define strictly convex spaces.
-/

open set
open_locale convex pointwise

variables {ð E F Î² : Type*}

open function set
open_locale convex

section ordered_semiring
variables [ordered_semiring ð] [topological_space E] [topological_space F]

section add_comm_monoid
variables [add_comm_monoid E] [add_comm_monoid F]

section has_scalar
variables (ð) [has_scalar ð E] [has_scalar ð F] (s : set E)

/-- A set is strictly convex if the open segment between any two distinct points lies is in its
interior. This basically means "convex and not flat on the boundary". -/
def strict_convex : Prop :=
s.pairwise $ Î» x y, â â¦a b : ðâ¦, 0 < a â 0 < b â a + b = 1 â a â¢ x + b â¢ y â interior s

variables {ð s} {x y : E}

lemma strict_convex_iff_open_segment_subset :
  strict_convex ð s â s.pairwise (Î» x y, open_segment ð x y â interior s) :=
begin
  split,
  { rintro h x hx y hy hxy z â¨a, b, ha, hb, hab, rflâ©,
    exact h hx hy hxy ha hb hab },
  { rintro h x hx y hy hxy a b ha hb hab,
    exact h hx hy hxy â¨a, b, ha, hb, hab, rflâ© }
end

lemma strict_convex.open_segment_subset (hs : strict_convex ð s) (hx : x â s) (hy : y â s)
  (h : x â  y) :
  open_segment ð x y â interior s :=
strict_convex_iff_open_segment_subset.1 hs hx hy h

lemma strict_convex_empty : strict_convex ð (â : set E) := pairwise_empty _

lemma strict_convex_univ : strict_convex ð (univ : set E) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  rw interior_univ,
  exact mem_univ _,
end

protected lemma strict_convex.inter {t : set E} (hs : strict_convex ð s) (ht : strict_convex ð t) :
  strict_convex ð (s â© t) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  rw interior_inter,
  exact â¨hs hx.1 hy.1 hxy ha hb hab, ht hx.2 hy.2 hxy ha hb habâ©,
end

lemma directed.strict_convex_Union {Î¹ : Sort*} {s : Î¹ â set E} (hdir : directed (â) s)
  (hs : â â¦i : Î¹â¦, strict_convex ð (s i)) :
  strict_convex ð (â i, s i) :=
begin
  rintro x hx y hy hxy a b ha hb hab,
  rw mem_Union at hx hy,
  obtain â¨i, hxâ© := hx,
  obtain â¨j, hyâ© := hy,
  obtain â¨k, hik, hjkâ© := hdir i j,
  exact interior_mono (subset_Union s k) (hs (hik hx) (hjk hy) hxy ha hb hab),
end

lemma directed_on.strict_convex_sUnion {S : set (set E)} (hdir : directed_on (â) S)
  (hS : â s â S, strict_convex ð s) :
  strict_convex ð (ââ S) :=
begin
  rw sUnion_eq_Union,
  exact (directed_on_iff_directed.1 hdir).strict_convex_Union (Î» s, hS _ s.2),
end

end has_scalar

section module
variables [module ð E] [module ð F] {s : set E}

protected lemma strict_convex.convex (hs : strict_convex ð s) : convex ð s :=
convex_iff_pairwise_pos.2 $ Î» x hx y hy hxy a b ha hb hab, interior_subset $ hs hx hy hxy ha hb hab

protected lemma convex.strict_convex (h : is_open s) (hs : convex ð s) : strict_convex ð s :=
Î» x hx y hy _ a b ha hb hab, h.interior_eq.symm â¸ hs hx hy ha.le hb.le hab

lemma is_open.strict_convex_iff (h : is_open s) : strict_convex ð s â convex ð s :=
â¨strict_convex.convex, convex.strict_convex hâ©

lemma strict_convex_singleton (c : E) : strict_convex ð ({c} : set E) := pairwise_singleton _ _

lemma set.subsingleton.strict_convex (hs : s.subsingleton) : strict_convex ð s := hs.pairwise _

lemma strict_convex.linear_image (hs : strict_convex ð s) (f : E ââ[ð] F) (hf : is_open_map f) :
  strict_convex ð (f '' s) :=
begin
  rintro _ â¨x, hx, rflâ© _ â¨y, hy, rflâ© hxy a b ha hb hab,
  exact hf.image_interior_subset _
    â¨a â¢ x + b â¢ y, hs hx hy (ne_of_apply_ne _ hxy) ha hb hab,
    by rw [f.map_add, f.map_smul, f.map_smul]â©,
end

lemma strict_convex.is_linear_image (hs : strict_convex ð s) {f : E â F} (h : is_linear_map ð f)
  (hf : is_open_map f) :
  strict_convex ð (f '' s) :=
hs.linear_image (h.mk' f) hf

lemma strict_convex.linear_preimage {s : set F} (hs : strict_convex ð s) (f : E ââ[ð] F)
  (hf : continuous f) (hfinj : injective f) :
  strict_convex ð (s.preimage f) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  refine preimage_interior_subset_interior_preimage hf _,
  rw [mem_preimage, f.map_add, f.map_smul, f.map_smul],
  exact hs hx hy (hfinj.ne hxy) ha hb hab,
end

lemma strict_convex.is_linear_preimage {s : set F} (hs : strict_convex ð s) {f : E â F}
  (h : is_linear_map ð f) (hf : continuous f) (hfinj : injective f) :
  strict_convex ð (s.preimage f) :=
hs.linear_preimage (h.mk' f) hf hfinj

section linear_ordered_cancel_add_comm_monoid
variables [topological_space Î²] [linear_ordered_cancel_add_comm_monoid Î²] [order_topology Î²]
  [module ð Î²] [ordered_smul ð Î²]

lemma strict_convex_Iic (r : Î²) : strict_convex ð (Iic r) :=
begin
  rintro x (hx : x â¤ r) y (hy : y â¤ r) hxy a b ha hb hab,
  refine (subset_interior_iff_subset_of_open is_open_Iio).2 Iio_subset_Iic_self _,
  rw âconvex.combo_self hab r,
  obtain rfl | hx := hx.eq_or_lt,
  { exact add_lt_add_left (smul_lt_smul_of_pos (hy.lt_of_ne hxy.symm) hb) _ },
  obtain rfl | hy := hy.eq_or_lt,
  { exact add_lt_add_right (smul_lt_smul_of_pos hx ha) _ },
  { exact add_lt_add (smul_lt_smul_of_pos hx ha) (smul_lt_smul_of_pos hy hb) }
end

lemma strict_convex_Ici (r : Î²) : strict_convex ð (Ici r) :=
@strict_convex_Iic ð (order_dual Î²) _ _ _ _ _ _ r

lemma strict_convex_Icc (r s : Î²) : strict_convex ð (Icc r s) :=
(strict_convex_Ici r).inter $ strict_convex_Iic s

lemma strict_convex_Iio (r : Î²) : strict_convex ð (Iio r) :=
(convex_Iio r).strict_convex is_open_Iio

lemma strict_convex_Ioi (r : Î²) : strict_convex ð (Ioi r) :=
(convex_Ioi r).strict_convex is_open_Ioi

lemma strict_convex_Ioo (r s : Î²) : strict_convex ð (Ioo r s) :=
(strict_convex_Ioi r).inter $ strict_convex_Iio s

lemma strict_convex_Ico (r s : Î²) : strict_convex ð (Ico r s) :=
(strict_convex_Ici r).inter $ strict_convex_Iio s

lemma strict_convex_Ioc (r s : Î²) : strict_convex ð (Ioc r s) :=
(strict_convex_Ioi r).inter $ strict_convex_Iic s

lemma strict_convex_interval (r s : Î²) : strict_convex ð (interval r s) :=
strict_convex_Icc _ _

end linear_ordered_cancel_add_comm_monoid
end module
end add_comm_monoid

section add_cancel_comm_monoid
variables [add_cancel_comm_monoid E] [has_continuous_add E] [module ð E] {s : set E}

/-- The translation of a strict_convex set is also strict_convex. -/
lemma strict_convex.preimage_add_right (hs : strict_convex ð s) (z : E) :
  strict_convex ð ((Î» x, z + x) â»Â¹' s) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  refine preimage_interior_subset_interior_preimage (continuous_add_left _) _,
  have h := hs hx hy ((add_right_injective _).ne hxy) ha hb hab,
  rwa [smul_add, smul_add, add_add_add_comm, âadd_smul, hab, one_smul] at h,
end

/-- The translation of a strict_convex set is also strict_convex. -/
lemma strict_convex.preimage_add_left (hs : strict_convex ð s) (z : E) :
  strict_convex ð ((Î» x, x + z) â»Â¹' s) :=
by simpa only [add_comm] using hs.preimage_add_right z

end add_cancel_comm_monoid

section add_comm_group
variables [add_comm_group E] [module ð E] {s t : set E}

lemma strict_convex.add_left [has_continuous_add E] (hs : strict_convex ð s) (z : E) :
  strict_convex ð ((Î» x, z + x) '' s) :=
begin
  rintro _ â¨x, hx, rflâ© _ â¨y, hy, rflâ© hxy a b ha hb hab,
  refine (is_open_map_add_left _).image_interior_subset _ _,
  refine â¨a â¢ x + b â¢ y, hs hx hy (ne_of_apply_ne _ hxy) ha hb hab, _â©,
  rw [smul_add, smul_add, add_add_add_comm, âadd_smul, hab, one_smul],
end

lemma strict_convex.add_right [has_continuous_add E] (hs : strict_convex ð s) (z : E) :
  strict_convex ð ((Î» x, x + z) '' s) :=
by simpa only [add_comm] using hs.add_left z

lemma strict_convex.add [has_continuous_add E] {t : set E} (hs : strict_convex ð s)
  (ht : strict_convex ð t) :
  strict_convex ð (s + t) :=
begin
  rintro _ â¨v, w, hv, hw, rflâ© _ â¨x, y, hx, hy, rflâ© h a b ha hb hab,
  rw [smul_add, smul_add, add_add_add_comm],
  obtain rfl | hvx := eq_or_ne v x,
  { rw convex.combo_self hab,
    suffices : v + (a â¢ w + b â¢ y) â interior ({v} + t),
    { exact interior_mono (add_subset_add (singleton_subset_iff.2 hv) (subset.refl _)) this },
    rw singleton_add,
    exact (is_open_map_add_left _).image_interior_subset _
      (mem_image_of_mem _ $ ht hw hy (ne_of_apply_ne _ h) ha hb hab) },
  obtain rfl | hwy := eq_or_ne w y,
  { rw convex.combo_self hab,
    suffices : a â¢ v + b â¢ x + w â interior (s + {w}),
    { exact interior_mono (add_subset_add (subset.refl _) (singleton_subset_iff.2 hw)) this },
    rw add_singleton,
    exact (is_open_map_add_right _).image_interior_subset _
      (mem_image_of_mem _ $ hs hv hx hvx ha hb hab) },
  exact subset_interior_add (add_mem_add (hs hv hx hvx ha hb hab) $ ht hw hy hwy ha hb hab),
end

end add_comm_group
end ordered_semiring

section ordered_comm_semiring
variables [ordered_comm_semiring ð] [topological_space ð] [topological_space E]

section add_comm_group
variables [add_comm_group E] [module ð E] [no_zero_smul_divisors ð E] [has_continuous_smul ð E]
  {s : set E}

lemma strict_convex.preimage_smul (hs : strict_convex ð s) (c : ð) :
  strict_convex ð ((Î» z, c â¢ z) â»Â¹' s) :=
begin
  classical,
  obtain rfl | hc := eq_or_ne c 0,
  { simp_rw [zero_smul, preimage_const],
    split_ifs,
    { exact strict_convex_univ },
    { exact strict_convex_empty } },
  refine hs.linear_preimage (linear_map.lsmul _ _ c) _ (smul_right_injective E hc),
  unfold linear_map.lsmul linear_map.mkâ linear_map.mkâ' linear_map.mkâ'ââ,
  exact continuous_const.smul continuous_id,
end

end add_comm_group
end ordered_comm_semiring

section ordered_ring
variables [ordered_ring ð] [topological_space E] [topological_space F]

section add_comm_group
variables [add_comm_group E] [add_comm_group F] [module ð E] [module ð F] {s : set E} {x y : E}

lemma strict_convex.eq_of_open_segment_subset_frontier [nontrivial ð] [densely_ordered ð]
  (hs : strict_convex ð s) (hx : x â s) (hy : y â s) (h : open_segment ð x y â frontier s) :
  x = y :=
begin
  obtain â¨a, haâ, haââ© := densely_ordered.dense (0 : ð) 1 zero_lt_one,
  classical,
  by_contra hxy,
  exact (h â¨a, 1 - a, haâ, sub_pos_of_lt haâ, add_sub_cancel'_right _ _, rflâ©).2
    (hs hx hy hxy haâ (sub_pos_of_lt haâ) $ add_sub_cancel'_right _ _),
end

lemma strict_convex.add_smul_mem (hs : strict_convex ð s) (hx : x â s) (hxy : x + y â s)
  (hy : y â  0) {t : ð} (htâ : 0 < t) (htâ : t < 1) :
  x + t â¢ y â interior s :=
begin
  have h : x + t â¢ y = (1 - t) â¢ x + t â¢ (x + y),
  { rw [smul_add, âadd_assoc, âadd_smul, sub_add_cancel, one_smul] },
  rw h,
  refine hs hx hxy (Î» h, hy $ add_left_cancel _) (sub_pos_of_lt htâ) htâ (sub_add_cancel _ _),
  exact x,
  rw [âh, add_zero],
end

lemma strict_convex.smul_mem_of_zero_mem (hs : strict_convex ð s) (zero_mem : (0 : E) â s)
  (hx : x â s) (hxâ : x â  0) {t : ð} (htâ : 0 < t) (htâ : t < 1) :
  t â¢ x â interior s :=
by simpa using hs.add_smul_mem zero_mem (by simpa using hx) hxâ htâ htâ

lemma strict_convex.add_smul_sub_mem (h : strict_convex ð s) (hx : x â s) (hy : y â s) (hxy : x â  y)
  {t : ð} (htâ : 0 < t) (htâ : t < 1) : x + t â¢ (y - x) â interior s :=
begin
  apply h.open_segment_subset hx hy hxy,
  rw open_segment_eq_image',
  exact mem_image_of_mem _ â¨htâ, htââ©,
end

/-- The preimage of a strict_convex set under an affine map is strict_convex. -/
lemma strict_convex.affine_preimage {s : set F} (hs : strict_convex ð s) {f : E âáµ[ð] F}
  (hf : continuous f) (hfinj : injective f) :
  strict_convex ð (f â»Â¹' s) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  refine preimage_interior_subset_interior_preimage hf _,
  rw [mem_preimage, convex.combo_affine_apply hab],
  exact hs hx hy (hfinj.ne hxy) ha hb hab,
end

/-- The image of a strict_convex set under an affine map is strict_convex. -/
lemma strict_convex.affine_image (hs : strict_convex ð s) {f : E âáµ[ð] F} (hf : is_open_map f) :
  strict_convex ð (f '' s) :=
begin
  rintro _ â¨x, hx, rflâ© _ â¨y, hy, rflâ© hxy a b ha hb hab,
  exact hf.image_interior_subset _ â¨a â¢ x + b â¢ y, â¨hs hx hy (ne_of_apply_ne _ hxy) ha hb hab,
    convex.combo_affine_apply habâ©â©,
end

lemma strict_convex.neg [topological_add_group E] (hs : strict_convex ð s) :
  strict_convex ð ((Î» z, -z) '' s) :=
hs.is_linear_image is_linear_map.is_linear_map_neg (homeomorph.neg E).is_open_map

lemma strict_convex.neg_preimage [topological_add_group E] (hs : strict_convex ð s) :
  strict_convex ð ((Î» z, -z) â»Â¹' s) :=
hs.is_linear_preimage is_linear_map.is_linear_map_neg continuous_id.neg neg_injective

end add_comm_group
end ordered_ring

section linear_ordered_field
variables [linear_ordered_field ð] [topological_space E]

section add_comm_group
variables [add_comm_group E] [add_comm_group F] [module ð E] [module ð F] {s : set E} {x : E}

lemma strict_convex.smul [topological_space ð] [has_continuous_smul ð E] (hs : strict_convex ð s)
  (c : ð) :
  strict_convex ð (c â¢ s) :=
begin
  obtain rfl | hc := eq_or_ne c 0,
  { exact (subsingleton_zero_smul_set _).strict_convex },
  { exact hs.linear_image (linear_map.lsmul _ _ c) (is_open_map_smulâ hc) }
end

lemma strict_convex.affinity [topological_space ð] [has_continuous_add E] [has_continuous_smul ð E]
  (hs : strict_convex ð s) (z : E) (c : ð) :
  strict_convex ð ((Î» x, z + c â¢ x) '' s) :=
begin
  have h := (hs.smul c).add_left z,
  rwa [âimage_smul, image_image] at h,
end

/-- Alternative definition of set strict_convexity, using division. -/
lemma strict_convex_iff_div :
  strict_convex ð s â s.pairwise
    (Î» x y, â â¦a b : ðâ¦, 0 < a â 0 < b â (a / (a + b)) â¢ x + (b / (a + b)) â¢ y â interior s) :=
â¨Î» h x hx y hy hxy a b ha hb, begin
  apply h hx hy hxy (div_pos ha $ add_pos ha hb) (div_pos hb $ add_pos ha hb),
  rw âadd_div,
  exact div_self (add_pos ha hb).ne',
end, Î» h x hx y hy hxy a b ha hb hab, by convert h hx hy hxy ha hb; rw [hab, div_one] â©

lemma strict_convex.mem_smul_of_zero_mem (hs : strict_convex ð s) (zero_mem : (0 : E) â s)
  (hx : x â s) (hxâ : x â  0) {t : ð} (ht : 1 < t) :
  x â t â¢ interior s :=
begin
  rw mem_smul_set_iff_inv_smul_memâ (zero_lt_one.trans ht).ne',
  exact hs.smul_mem_of_zero_mem zero_mem hx hxâ (inv_pos.2 $ zero_lt_one.trans ht)  (inv_lt_one ht),
end

end add_comm_group
end linear_ordered_field

/-!
#### Convex sets in an ordered space

Relates `convex` and `set.ord_connected`.
-/

section
variables [topological_space E]

@[simp] lemma strict_convex_iff_convex [linear_ordered_field ð] [topological_space ð]
  [order_topology ð] {s : set ð} :
  strict_convex ð s â convex ð s :=
begin
  refine â¨strict_convex.convex, Î» hs, strict_convex_iff_open_segment_subset.2 (Î» x hx y hy hxy, _)â©,
  obtain h | h := hxy.lt_or_lt,
  { refine (open_segment_subset_Ioo h).trans _,
    rw âinterior_Icc,
    exact interior_mono (Icc_subset_segment.trans $ hs.segment_subset hx hy) },
  { rw open_segment_symm,
    refine (open_segment_subset_Ioo h).trans _,
    rw âinterior_Icc,
    exact interior_mono (Icc_subset_segment.trans $ hs.segment_subset hy hx) }
end

lemma strict_convex_iff_ord_connected [linear_ordered_field ð] [topological_space ð]
  [order_topology ð] {s : set ð} :
  strict_convex ð s â s.ord_connected :=
strict_convex_iff_convex.trans convex_iff_ord_connected

alias strict_convex_iff_ord_connected â strict_convex.ord_connected _

end
