/-
Copyright (c) 2021 YaΓ«l Dillies, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: YaΓ«l Dillies, Bhavik Mehta
-/
import analysis.convex.extreme
import analysis.convex.function
import analysis.normed_space.ordered

/-!
# Exposed sets

This file defines exposed sets and exposed points for sets in a real vector space.

An exposed subset of `A` is a subset of `A` that is the set of all maximal points of a functional
(a continuous linear map `E β π`) over `A`. By convention, `β` is an exposed subset of all sets.
This allows for better functioriality of the definition (the intersection of two exposed subsets is
exposed, faces of a polytope form a bounded lattice).
This is an analytic notion of "being on the side of". It is stronger than being extreme (see
`is_exposed.is_extreme`), but weaker (for exposed points) than being a vertex.

An exposed set of `A` is sometimes called a "face of `A`", but we decided to reserve this
terminology to the more specific notion of a face of a polytope (sometimes hopefully soon out
on mathlib!).

## Main declarations

* `is_exposed π A B`: States that `B` is an exposed set of `A` (in the literature, `A` is often
  implicit).
* `is_exposed.is_extreme`: An exposed set is also extreme.

## References

See chapter 8 of [Barry Simon, *Convexity*][simon2011]

## TODO

Define intrinsic frontier/interior and prove the lemmas related to exposed sets and points.

Generalise to Locally Convex Topological Vector Spacesβ’

More not-yet-PRed stuff is available on the branch `sperner_again`.
-/

open_locale classical affine big_operators
open set

variables (π : Type*) {E : Type*} [normed_linear_ordered_field π] [normed_group E]
  [normed_space π E] {l : E βL[π] π} {A B C : set E} {X : finset E} {x : E}

/-- A set `B` is exposed with respect to `A` iff it maximizes some functional over `A` (and contains
all points maximizing it). Written `is_exposed π A B`. -/
def is_exposed (A B : set E) : Prop :=
B.nonempty β β l : E βL[π] π, B = {x β A | β y β A, l y β€ l x}

variables {π}

/-- A useful way to build exposed sets from intersecting `A` with halfspaces (modelled by an
inequality with a functional). -/
def continuous_linear_map.to_exposed (l : E βL[π] π) (A : set E) : set E :=
{x β A | β y β A, l y β€ l x}

lemma continuous_linear_map.to_exposed.is_exposed : is_exposed π A (l.to_exposed A) := Ξ» h, β¨l, rflβ©

lemma is_exposed_empty : is_exposed π A β :=
Ξ» β¨x, hxβ©, by { exfalso, exact hx }

namespace is_exposed

protected lemma subset (hAB : is_exposed π A B) : B β A :=
begin
  rintro x hx,
  obtain β¨_, rflβ© := hAB β¨x, hxβ©,
  exact hx.1,
end

@[refl] protected lemma refl (A : set E) : is_exposed π A A :=
Ξ» β¨w, hwβ©, β¨0, subset.antisymm (Ξ» x hx, β¨hx, Ξ» y hy, by exact le_refl 0β©) (Ξ» x hx, hx.1)β©

protected lemma antisymm (hB : is_exposed π A B) (hA : is_exposed π B A) :
  A = B :=
hA.subset.antisymm hB.subset

/- `is_exposed` is *not* transitive: Consider a (topologically) open cube with vertices
`Aβββ, ..., Aβββ` and add to it the triangle `AβββAβββAβββ`. Then `AβββAβββ` is an exposed subset
of `AβββAβββAβββ` which is an exposed subset of the cube, but `AβββAβββ` is not itself an exposed
subset of the cube. -/

protected lemma mono (hC : is_exposed π A C) (hBA : B β A) (hCB : C β B) :
  is_exposed π B C :=
begin
  rintro β¨w, hwβ©,
  obtain β¨l, rflβ© := hC β¨w, hwβ©,
  exact β¨l, subset.antisymm (Ξ» x hx, β¨hCB hx, Ξ» y hy, hx.2 y (hBA hy)β©)
    (Ξ» x hx, β¨hBA hx.1, Ξ» y hy, (hw.2 y hy).trans (hx.2 w (hCB hw))β©)β©,
end

/-- If `B` is an exposed subset of `A`, then `B` is the intersection of `A` with some closed
halfspace. The converse is *not* true. It would require that the corresponding open halfspace
doesn't intersect `A`. -/
lemma eq_inter_halfspace (hAB : is_exposed π A B) :
  β l : E βL[π] π, β a, B = {x β A | a β€ l x} :=
begin
  obtain hB | hB := B.eq_empty_or_nonempty,
  { refine β¨0, 1, _β©,
    rw [hB, eq_comm, eq_empty_iff_forall_not_mem],
    rintro x β¨-, hβ©,
    rw continuous_linear_map.zero_apply at h,
    linarith },
  obtain β¨l, rflβ© := hAB hB,
  obtain β¨w, hwβ© := hB,
  exact β¨l, l w, subset.antisymm (Ξ» x hx, β¨hx.1, hx.2 w hw.1β©)
    (Ξ» x hx, β¨hx.1, Ξ» y hy, (hw.2 y hy).trans hx.2β©)β©,
end

protected lemma inter (hB : is_exposed π A B) (hC : is_exposed π A C) :
  is_exposed π A (B β© C) :=
begin
  rintro β¨w, hwB, hwCβ©,
  obtain β¨lβ, rflβ© := hB β¨w, hwBβ©,
  obtain β¨lβ, rflβ© := hC β¨w, hwCβ©,
  refine β¨lβ + lβ, subset.antisymm _ _β©,
  { rintro x β¨β¨hxA, hxBβ©, β¨-, hxCβ©β©,
    exact β¨hxA, Ξ» z hz, add_le_add (hxB z hz) (hxC z hz)β© },
  rintro x β¨hxA, hxβ©,
  refine β¨β¨hxA, Ξ» y hy, _β©, hxA, Ξ» y hy, _β©,
  { exact (add_le_add_iff_right (lβ x)).1 ((add_le_add (hwB.2 y hy) (hwC.2 x hxA)).trans
      (hx w hwB.1)) },
  { exact (add_le_add_iff_left (lβ x)).1 (le_trans (add_le_add (hwB.2 x hxA) (hwC.2 y hy))
    (hx w hwB.1)) }
end

lemma sInter {F : finset (set E)} (hF : F.nonempty)
  (hAF : β B β F, is_exposed π A B) :
  is_exposed π A (ββ F) :=
begin
  revert hF F,
  refine finset.induction _ _,
  { rintro h,
    exfalso,
    exact empty_not_nonempty h },
  rintro C F _ hF _ hCF,
  rw [finset.coe_insert, sInter_insert],
  obtain rfl | hFnemp := F.eq_empty_or_nonempty,
  { rw [finset.coe_empty, sInter_empty, inter_univ],
    exact hCF C (finset.mem_singleton_self C) },
  exact (hCF C (finset.mem_insert_self C F)).inter (hF hFnemp (Ξ» B hB,
    hCF B(finset.mem_insert_of_mem hB))),
end

lemma inter_left (hC : is_exposed π A C) (hCB : C β B) :
  is_exposed π (A β© B) C :=
begin
  rintro β¨w, hwβ©,
  obtain β¨l, rflβ© := hC β¨w, hwβ©,
  exact β¨l, subset.antisymm (Ξ» x hx, β¨β¨hx.1, hCB hxβ©, Ξ» y hy, hx.2 y hy.1β©)
    (Ξ» x β¨β¨hxC, _β©, hxβ©, β¨hxC, Ξ» y hy, (hw.2 y hy).trans (hx w β¨hC.subset hw, hCB hwβ©)β©)β©,
end

lemma inter_right (hC : is_exposed π B C) (hCA : C β A) :
  is_exposed π (A β© B) C :=
begin
  rw inter_comm,
  exact hC.inter_left hCA,
end

protected lemma is_extreme (hAB : is_exposed π A B) :
  is_extreme π A B :=
begin
  refine β¨hAB.subset, Ξ» xβ xβ hxβA hxβA x hxB hx, _β©,
  obtain β¨l, rflβ© := hAB β¨x, hxBβ©,
  have hl : convex_on π univ l := l.to_linear_map.convex_on convex_univ,
  have hlxβ := hxB.2 xβ hxβA,
  have hlxβ := hxB.2 xβ hxβA,
  refine β¨β¨hxβA, Ξ» y hy, _β©, β¨hxβA, Ξ» y hy, _β©β©,
  { rw hlxβ.antisymm (hl.le_left_of_right_le (mem_univ _) (mem_univ _) hx hlxβ),
    exact hxB.2 y hy },
  { rw hlxβ.antisymm (hl.le_right_of_left_le (mem_univ _) (mem_univ _) hx hlxβ),
    exact hxB.2 y hy }
end

protected lemma convex (hAB : is_exposed π A B) (hA : convex π A) :
  convex π B :=
begin
  obtain rfl | hB := B.eq_empty_or_nonempty,
  { exact convex_empty },
  obtain β¨l, rflβ© := hAB hB,
  exact Ξ» xβ xβ hxβ hxβ a b ha hb hab, β¨hA hxβ.1 hxβ.1 ha hb hab, Ξ» y hy,
    ((l.to_linear_map.concave_on convex_univ).convex_ge _
    β¨mem_univ _, hxβ.2 y hyβ© β¨mem_univ _, hxβ.2 y hyβ© ha hb hab).2β©,
end

protected lemma is_closed [order_closed_topology π] (hAB : is_exposed π A B) (hA : is_closed A) :
  is_closed B :=
begin
  obtain β¨l, a, rflβ© := hAB.eq_inter_halfspace,
  exact hA.is_closed_le continuous_on_const l.continuous.continuous_on,
end

protected lemma is_compact [order_closed_topology π] (hAB : is_exposed π A B) (hA : is_compact A) :
  is_compact B :=
compact_of_is_closed_subset hA (hAB.is_closed hA.is_closed) hAB.subset

end is_exposed

variables (π)

/-- A point is exposed with respect to `A` iff there exists an hyperplane whose intersection with
`A` is exactly that point. -/
def set.exposed_points (A : set E) :
  set E :=
{x β A | β l : E βL[π] π, β y β A, l y β€ l x β§ (l x β€ l y β y = x)}

variables {π}

lemma exposed_point_def :
  x β A.exposed_points π β x β A β§ β l : E βL[π] π, β y β A, l y β€ l x β§ (l x β€ l y β y = x) :=
iff.rfl

lemma exposed_points_subset :
  A.exposed_points π β A :=
Ξ» x hx, hx.1

@[simp] lemma exposed_points_empty :
  (β : set E).exposed_points π = β :=
subset_empty_iff.1 exposed_points_subset

/-- Exposed points exactly correspond to exposed singletons. -/
lemma mem_exposed_points_iff_exposed_singleton :
  x β A.exposed_points π β is_exposed π A {x} :=
begin
  use Ξ» β¨hxA, l, hlβ© h, β¨l, eq.symm $ eq_singleton_iff_unique_mem.2 β¨β¨hxA, Ξ» y hy, (hl y hy).1β©,
    Ξ» z hz, (hl z hz.1).2 (hz.2 x hxA)β©β©,
  rintro h,
  obtain β¨l, hlβ© := h β¨x, mem_singleton _β©,
  rw [eq_comm, eq_singleton_iff_unique_mem] at hl,
  exact β¨hl.1.1, l, Ξ» y hy, β¨hl.1.2 y hy, Ξ» hxy, hl.2 y β¨hy, Ξ» z hz, (hl.1.2 z hz).trans hxyβ©β©β©,
end

lemma exposed_points_subset_extreme_points :
  A.exposed_points π β A.extreme_points π :=
Ξ» x hx, mem_extreme_points_iff_extreme_singleton.2
  (mem_exposed_points_iff_exposed_singleton.1 hx).is_extreme
