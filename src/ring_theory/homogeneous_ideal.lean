/-
Copyright (c) 2021 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang Eric Wieser
-/

import algebra.direct_sum.ring
import ring_theory.ideal.basic
import ring_theory.ideal.operations


/-!

# Homogeneous ideal of a graded commutative ring

This file defines properties of ideals of graded commutative ring `⨁ i, A i`

-/

noncomputable theory

open_locale direct_sum classical big_operators
open set direct_sum


variables {ι : Type*} {A : ι → Type*} [Π i, add_comm_group (A i)]

/-- An element `x : ⨁ i, A i` is a homogeneous element if it is a member of one of the summand. -/
def is_homogeneous_element (x : ⨁ i, A i) : Prop := ∃ (y : graded_monoid A), x = of A y.fst y.snd
/-- Convert a homogeneous element `x` to its counter part in the summand. -/
def is_homogeneous_element.to {x : ⨁ i, A i} (H : is_homogeneous_element x) :
  graded_monoid A := H.some

/-- this might be useful, but I don't know where to put it -/
def graded_monoid.to_direct_sum [add_comm_monoid ι] [gcomm_semiring A] :
  (graded_monoid A) →* (⨁ i, A i) :=
{ to_fun := λ a, of A a.fst a.snd,
  map_one' := rfl,
  map_mul' := λ x y, (of_mul_of _ _).symm, }

section defs

/-- A homogeneous ideal of `⨁ i, A i` is an `I : ideal (⨁ i, A i)` such that `I` is generated by
some set `S : set (graded_mooid A)` such that `I` is generated by the image of `S` in `⨁ i, A i`.-/
def homogeneous_ideal [add_comm_monoid ι] [gcomm_semiring A] (I : ideal (⨁ i, A i)) : Prop :=
  ∃ S : set (graded_monoid A), I = ideal.span (graded_monoid.to_direct_sum '' S)
/-- Equivalently, an `I : ideal (⨁ i, A i)` is homogeneous iff `I` is spaned by its homogeneous
element-/
def homogeneous_ideal' [add_comm_monoid ι] [gcomm_semiring A] (I : ideal (⨁ i, A i)) : Prop :=
  I = ideal.span {x | x ∈ I ∧ is_homogeneous_element x }

lemma homogeneous_ideal_iff_homogeneous_ideal' [add_comm_monoid ι] [gcomm_semiring A]
  (I : ideal (⨁ i, A i)) :
  homogeneous_ideal I ↔ homogeneous_ideal' I :=
⟨λ HI, begin
  rcases HI with ⟨S, HS⟩,
  ext, split; intro hx,
  { have HS₂ : graded_monoid.to_direct_sum '' S ⊆ {x | x ∈ I ∧ is_homogeneous_element x},
    { intros y hy, split,
      { suffices : (graded_monoid.to_direct_sum '' S) ⊆ I, refine this _, exact hy,
        rw [←ideal.span_le, HS], exact le_refl _, },
        { simp only [mem_image] at hy,
        rcases hy with ⟨x, _, hx⟩,
        refine ⟨x, _⟩, rw ←hx, refl, } },
    suffices : ideal.span (graded_monoid.to_direct_sum '' S)
      ≤ ideal.span {x ∈ I | is_homogeneous_element x},
    refine this _, rw ←HS, exact hx,
    exact ideal.span_mono HS₂ },
  { suffices : {x | x ∈ ideal.span (graded_monoid.to_direct_sum '' S) ∧
      is_homogeneous_element x} ⊆ I,
    have H : ideal.span {x | x ∈ ideal.span (graded_monoid.to_direct_sum '' S) ∧
      is_homogeneous_element x} ≤ ideal.span I,
    { exact ideal.span_mono this },
    rw [←HS, ideal.span_eq] at H,
    refine H _, exact hx,
    rintros y ⟨hy₁, _⟩, rw ←HS at hy₁, exact hy₁ },
end, λ HI, begin
  use graded_monoid.to_direct_sum ⁻¹' {x | x ∈ I ∧ is_homogeneous_element x },
  rw image_preimage_eq_iff.mpr, exact HI,

  rintros y ⟨hy₁, hy₂⟩, choose a ha using hy₂,
  rw [mem_range], use a, rw ha, refl,
end⟩

lemma homogeneous_ideal.mem_iff [add_comm_monoid ι] [gcomm_semiring A]
  (I : ideal (⨁ i, A i)) (HI : homogeneous_ideal I) (x : ⨁ i, A i) :
  x ∈ I ↔ ∀ (i : ι), of A i (x i) ∈ I := sorry

end defs

section operations

open_locale pointwise

variables [add_comm_monoid ι] [gcomm_semiring A]

lemma homogeneous_ideal.mul {I J : ideal (⨁ i, A i)}
  (HI : homogeneous_ideal I) (HJ : homogeneous_ideal J):
  homogeneous_ideal (I * J) :=
begin
  obtain ⟨si, rfl⟩ := HI,
  obtain ⟨sj, rfl⟩ := HJ,
  refine ⟨si * sj, _⟩,
  rw ideal.span_mul_span',
  exact congr_arg _ (image_mul graded_monoid.to_direct_sum.to_mul_hom).symm,
end

lemma homogeneous_ideal.sup {I J : ideal (⨁ i, A i)}
  (HI : homogeneous_ideal I) (HJ : homogeneous_ideal J):
  homogeneous_ideal (I ⊔ J) :=
begin
  obtain ⟨si, rfl⟩ := HI,
  obtain ⟨sj, rfl⟩ := HJ,
  refine ⟨si ∪ sj, _⟩,
  rw image_union,
  exact (submodule.span_union _ _).symm,
end

private lemma homogeneous_ideal.inf_subset {I J : ideal (⨁ i, A i)}
  (HI : homogeneous_ideal I) (HJ : homogeneous_ideal J) :
  I ⊓ J ≤ ideal.span {x | x ∈ I ⊓ J ∧ is_homogeneous_element x} :=
begin
  rintro x ⟨hxi, hxj⟩,
  have hx : ∀ i, of A i (x i) ∈ I ⊓ J,
  { intro j, split; refine (homogeneous_ideal.mem_iff _ _ x).mp _ _; assumption },
  sorry,
end

private lemma homogeneous_ideal.subset_inf {I J : ideal (⨁ i, A i)}
  (HI : homogeneous_ideal I) (HJ : homogeneous_ideal J) :
  ideal.span {x | x ∈ I ⊓ J ∧ is_homogeneous_element x} ≤ I ⊓ J :=
begin
  intros x hx,
  { split,
    { simp only [set_like.mem_coe],
      rw [homogeneous_ideal_iff_homogeneous_ideal', homogeneous_ideal'] at HI,
      rw [HI, ideal.mem_span], intros K HK,
      replace HK := ideal.span_mono HK,
      rw [ideal.span_eq] at HK,
      have eq₁ : ideal.span {x | x ∈ I ⊓ J ∧ is_homogeneous_element x}
        ≤ ideal.span {x | x ∈ I ∧ is_homogeneous_element x},
      { apply ideal.span_mono, rintros y ⟨⟨hy₁, _⟩, hy₂⟩, refine ⟨hy₁, hy₂⟩, },
      refine HK _, refine eq₁ hx, },
    { simp only [set_like.mem_coe],
      rw [homogeneous_ideal_iff_homogeneous_ideal', homogeneous_ideal'] at HJ,
      rw [HJ, ideal.mem_span], intros K HK,
      replace HK := ideal.span_mono HK,
      rw [ideal.span_eq] at HK,
      have eq₁ : ideal.span {x | x ∈ I ⊓ J ∧ is_homogeneous_element x}
        ≤ ideal.span {x | x ∈ J ∧ is_homogeneous_element x},
      { apply ideal.span_mono, rintros y ⟨⟨_, hy₁⟩, hy₂⟩, refine ⟨hy₁, hy₂⟩, },
      refine HK _, refine eq₁ hx, },
  },
end

lemma homogeneous_ideal.inf {I J : ideal (⨁ i, A i)}
  (HI : homogeneous_ideal I) (HJ : homogeneous_ideal J) :
  homogeneous_ideal (I ⊓ J) :=
begin
  rw [homogeneous_ideal_iff_homogeneous_ideal', homogeneous_ideal'],
  exact le_antisymm (homogeneous_ideal.inf_subset HI HJ) (homogeneous_ideal.subset_inf HI HJ),
end

end operations
