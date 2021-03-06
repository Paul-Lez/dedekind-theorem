/-
Copyright (c) 2021 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta, Alena Gusakov, YaÃ«l Dillies
-/
import data.finset.lattice
import logic.function.iterate

/-!
# Shadows

This file defines shadows of a set family. The shadow of a set family is the set family of sets we
get by removing any element from any set of the original family. If one pictures `finset Î±` as a big
hypercube (each dimension being membership of a given element), then taking the shadow corresponds
to projecting each finset down once in all available directions.

## Main definitions

The `shadow` of a set family is everything we can get by removing an element from each set.

## Notation

`â ð` is notation for `shadow ð`. It is situated in locale `finset_family`.

We also maintain the convention that `a, b : Î±` are elements of the ground type, `s, t : finset Î±`
are finsets, and `ð, â¬ : finset (finset Î±)` are finset families.

## References

* https://github.com/b-mehta/maths-notes/blob/master/iii/mich/combinatorics.pdf
* http://discretemath.imp.fu-berlin.de/DMII-2015-16/kruskal.pdf

## Tags

shadow, set family
-/

open finset nat

variables {Î± : Type*}

namespace finset
variables [decidable_eq Î±] {ð : finset (finset Î±)} {s t : finset Î±} {a : Î±} {k : â}

/-- The shadow of a set family `ð` is all sets we can get by removing one element from any set in
`ð`, and the (`k` times) iterated shadow (`shadow^[k]`) is all sets we can get by removing `k`
elements from any set in `ð`. -/
def shadow (ð : finset (finset Î±)) : finset (finset Î±) := ð.sup (Î» s, s.image (erase s))

localized "notation `â `:90 := finset.shadow" in finset_family

/-- The shadow of the empty set is empty. -/
@[simp] lemma shadow_empty : â (â : finset (finset Î±)) = â := rfl

/-- The shadow is monotone. -/
@[mono] lemma shadow_monotone : monotone (shadow : finset (finset Î±) â finset (finset Î±)) :=
Î» ð â¬, sup_mono

/-- `s` is in the shadow of `ð` iff there is an `t â ð` from which we can remove one element to
get `s`. -/
lemma mem_shadow_iff : s â â ð â â t â ð, â a â t, erase t a = s :=
by simp only [shadow, mem_sup, mem_image]

lemma erase_mem_shadow (hs : s â ð) (ha : a â s) : erase s a â â ð :=
mem_shadow_iff.2 â¨s, hs, a, ha, rflâ©

/-- `t` is in the shadow of `ð` iff we can add an element to it so that the resulting finset is in
`ð`. -/
lemma mem_shadow_iff_insert_mem : s â â ð â â a â s, insert a s â ð :=
begin
  refine mem_shadow_iff.trans â¨_, _â©,
  { rintro â¨s, hs, a, ha, rflâ©,
    refine â¨a, not_mem_erase a s, _â©,
    rwa insert_erase ha },
  { rintro â¨a, ha, hsâ©,
    exact â¨insert a s, hs, a, mem_insert_self _ _, erase_insert haâ© }
end

/-- `s â â ð` iff `s` is exactly one element less than something from `ð` -/
lemma mem_shadow_iff_exists_mem_card_add_one :
  s â â ð â â t â ð, s â t â§ t.card = s.card + 1 :=
begin
  refine mem_shadow_iff_insert_mem.trans â¨_, _â©,
  { rintro â¨a, ha, hsâ©,
    exact â¨insert a s, hs, subset_insert _ _, card_insert_of_not_mem haâ© },
  { rintro â¨t, ht, hst, hâ©,
    obtain â¨a, haâ© : â a, t \ s = {a} :=
      card_eq_one.1 (by rw [card_sdiff hst, h, add_tsub_cancel_left]),
    exact â¨a, Î» hat,
      not_mem_sdiff_of_mem_right hat ((ha.ge : _ â _) $ mem_singleton_self a),
      by rwa [insert_eq a s, âha, sdiff_union_of_subset hst]â© }
end

/-- Being in the shadow of `ð` means we have a superset in `ð`. -/
lemma exists_subset_of_mem_shadow (hs : s â â ð) : â t â ð, s â t :=
let â¨t, ht, hstâ© := mem_shadow_iff_exists_mem_card_add_one.1 hs in â¨t, ht, hst.1â©

/-- `t â â^k ð` iff `t` is exactly `k` elements less than something in `ð`. -/
lemma mem_shadow_iff_exists_mem_card_add :
  s â (â^[k]) ð â â t â ð, s â t â§ t.card = s.card + k :=
begin
  induction k with k ih generalizing ð s,
  { refine â¨Î» hs, â¨s, hs, subset.refl _, rflâ©, _â©,
    rintro â¨t, ht, hst, hcardâ©,
    rwa eq_of_subset_of_card_le hst hcard.le },
  simp only [exists_prop, function.comp_app, function.iterate_succ],
  refine ih.trans _,
  clear ih,
  split,
  { rintro â¨t, ht, hst, hcardstâ©,
    obtain â¨u, hu, htu, hcardtuâ© := mem_shadow_iff_exists_mem_card_add_one.1 ht,
    refine â¨u, hu, hst.trans htu, _â©,
    rw [hcardtu, hcardst],
    refl },
  { rintro â¨t, ht, hst, hcardâ©,
    obtain â¨u, hsu, hut, huâ© := finset.exists_intermediate_set k
      (by { rw [add_comm, hcard], exact le_succ _ }) hst,
    rw add_comm at hu,
    refine â¨u, mem_shadow_iff_exists_mem_card_add_one.2 â¨t, ht, hut, _â©, hsu, huâ©,
    rw [hcard, hu],
    refl }
end

end finset
