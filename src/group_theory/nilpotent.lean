/-
Copyright (c) 2021 Kevin Buzzard. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Buzzard
-/

import group_theory.general_commutator
import group_theory.quotient_group

/-!

# Nilpotent groups

An API for nilpotent groups, that is, groups for which the upper central series
reaches `⊤`.

## Main definitions

Recall that if `H K : subgroup G` then `⁅H, K⁆ : subgroup G` is the subgroup of `G` generated
by the commutators `hkh⁻¹k⁻¹`. Recall also Lean's conventions that `⊤` denotes the
subgroup `G` of `G`, and `⊥` denotes the trivial subgroup `{1}`.

* `upper_central_series G : ℕ → subgroup G` : the upper central series of a group `G`.
     This is an increasing sequence of normal subgroups `H n` of `G` with `H 0 = ⊥` and
     `H (n + 1) / H n` is the centre of `G / H n`.
* `lower_central_series G : ℕ → subgroup G` : the lower central series of a group `G`.
     This is a decreasing sequence of normal subgroups `H n` of `G` with `H 0 = ⊤` and
     `H (n + 1) = ⁅H n, G⁆`.
* `is_nilpotent` : A group G is nilpotent if its upper central series reaches `⊤`, or
    equivalently if its lower central series reaches `⊥`.
* `nilpotency_class` : the length of the upper central series of a nilpotent group.
* `is_ascending_central_series (H : ℕ → subgroup G) : Prop` and
* `is_descending_central_series (H : ℕ → subgroup G) : Prop` : Note that in the literature
    a "central series" for a group is usually defined to be a *finite* sequence of normal subgroups
    `H 0`, `H 1`, ..., starting at `⊤`, finishing at `⊥`, and with each `H n / H (n + 1)`
    central in `G / H (n + 1)`. In this formalisation it is convenient to have two weaker predicates
    on an infinite sequence of subgroups `H n` of `G`: we say a sequence is a *descending central
    series* if it starts at `G` and `⁅H n, ⊤⁆ ⊆ H (n + 1)` for all `n`. Note that this series
    may not terminate at `⊥`, and the `H i` need not be normal. Similarly a sequence is an
    *ascending central series* if `H 0 = ⊥` and `⁅H (n + 1), ⊤⁆ ⊆ H n` for all `n`, again with no
    requirement that the series reaches `⊤` or that the `H i` are normal.

## Main theorems

`G` is *defined* to be nilpotent if the upper central series reaches `⊤`.
* `nilpotent_iff_finite_ascending_central_series` : `G` is nilpotent iff some ascending central
    series reaches `⊤`.
* `nilpotent_iff_finite_descending_central_series` : `G` is nilpotent iff some descending central
    series reaches `⊥`.
* `nilpotent_iff_lower` : `G` is nilpotent iff the lower central series reaches `⊥`.

## Warning

A "central series" is usually defined to be a finite sequence of normal subgroups going
from `⊥` to `⊤` with the property that each subquotient is contained within the centre of
the associated quotient of `G`. This means that if `G` is not nilpotent, then
none of what we have called `upper_central_series G`, `lower_central_series G` or
the sequences satisfying `is_ascending_central_series` or `is_descending_central_series`
are actually central series. Note that the fact that the upper and lower central series
are not central series if `G` is not nilpotent is a standard abuse of notation.

-/

open subgroup

variables {G : Type*} [group G] (H : subgroup G) [normal H]

/-- If `H` is a normal subgroup of `G`, then the set `{x : G | ∀ y : G, x*y*x⁻¹*y⁻¹ ∈ H}`
is a subgroup of `G` (because it is the preimage in `G` of the centre of the
quotient group `G/H`.)
-/
def upper_central_series_step : subgroup G :=
{ carrier := {x : G | ∀ y : G, x * y * x⁻¹ * y⁻¹ ∈ H},
  one_mem' := λ y, by simp [subgroup.one_mem],
  mul_mem' := λ a b ha hb y, begin
    convert subgroup.mul_mem _ (ha (b * y * b⁻¹)) (hb y) using 1,
    group,
  end,
  inv_mem' := λ x hx y, begin
    specialize hx y⁻¹,
    rw [mul_assoc, inv_inv] at ⊢ hx,
    exact subgroup.normal.mem_comm infer_instance hx,
  end }

lemma mem_upper_central_series_step (x : G) :
  x ∈ upper_central_series_step H ↔ ∀ y, x * y * x⁻¹ * y⁻¹ ∈ H := iff.rfl

open quotient_group

/-- The proof that `upper_central_series_step H` is the preimage of the centre of `G/H` under
the canonical surjection. -/
lemma upper_central_series_step_eq_comap_center :
  upper_central_series_step H = subgroup.comap (mk' H) (center (quotient H)) :=
begin
  ext,
  rw [mem_comap, mem_center_iff, forall_coe],
  apply forall_congr,
  intro y,
  change x * y * x⁻¹ * y⁻¹ ∈ H ↔ ((y * x : G) : quotient H) = (x * y : G),
  rw [eq_comm, eq_iff_div_mem, div_eq_mul_inv],
  congr' 2,
  group,
end

instance : normal (upper_central_series_step H) :=
begin
  rw upper_central_series_step_eq_comap_center,
  apply_instance,
end

variable (G)

/-- An auxiliary type-theoretic definition defining both the upper central series of
a group, and a proof that it is normal, all in one go. -/
def upper_central_series_aux : ℕ → Σ' (H : subgroup G), normal H
| 0 := ⟨⊥, infer_instance⟩
| (n + 1) := let un := upper_central_series_aux n, un_normal := un.2 in
   by exactI ⟨upper_central_series_step un.1, infer_instance⟩

/-- `upper_central_series G n` is the `n`th term in the upper central series of `G`. -/
def upper_central_series (n : ℕ) : subgroup G := (upper_central_series_aux G n).1

instance (n : ℕ) : normal (upper_central_series G n) := (upper_central_series_aux G n).2

lemma upper_central_series_zero_def : upper_central_series G 0 = ⊥ := rfl

/-- The `n+1`st term of the upper central series `H i` has underlying set equal to the `x` such
that `⁅x,G⁆ ⊆ H n`-/
lemma mem_upper_central_series_succ_iff {G : Type*} [group G] (n : ℕ) (x : G) :
  x ∈ upper_central_series G (n + 1) ↔
  ∀ y : G, x * y * x⁻¹ * y⁻¹ ∈ upper_central_series G n := iff.rfl

-- is_nilpotent is already defined in the root namespace (for elements of rings).
/-- A group `G` is nilpotent if its upper central series is eventually `G`. -/
class group.is_nilpotent (G : Type*) [group G] : Prop :=
(nilpotent [] : ∃ n : ℕ, upper_central_series G n = ⊤)

open group

section classical

open_locale classical

/-- The nilpotency class of a nilpotent group is the small natural `n` such that
the `n`'th term of the upper central series is `G`. -/
noncomputable def group.nilpotency_class (G : Type*) [group G] [is_nilpotent G] : ℕ :=
nat.find (is_nilpotent.nilpotent G)

end classical

variable {G}

/-- A sequence of subgroups of `G` is an ascending central series if `H 0` is trivial and
  `⁅H (n + 1), G⁆ ⊆ H n` for all `n`. Note that we do not require that `H n = G` for some `n`. -/
def is_ascending_central_series (H : ℕ → subgroup G) : Prop :=
  H 0 = ⊥ ∧ ∀ (x : G) (n : ℕ), x ∈ H (n + 1) → ∀ g, x * g * x⁻¹ * g⁻¹ ∈ H n

/-- A sequence of subgroups of `G` is a descending central series if `H 0` is `G` and
  `⁅H n, G⁆ ⊆ H (n + 1)` for all `n`. Note that we do not requre that `H n = {1}` for some `n`. -/
def is_descending_central_series (H : ℕ → subgroup G) := H 0 = ⊤ ∧
  ∀ (x : G) (n : ℕ), x ∈ H n → ∀ g, x * g * x⁻¹ * g⁻¹ ∈ H (n + 1)

/-- Any ascending central series for a group is bounded above by the upper central series. -/
lemma ascending_central_series_le_upper (H : ℕ → subgroup G) (hH : is_ascending_central_series H) :
  ∀ n : ℕ, H n ≤ upper_central_series G n
| 0 := hH.1.symm ▸ le_refl ⊥
| (n + 1) := begin
  specialize ascending_central_series_le_upper n,
  intros x hx,
  have := hH.2 x n hx,
  rw mem_upper_central_series_succ_iff,
  intro y,
  apply ascending_central_series_le_upper,
  apply this,
end

variable (G)

/-- The upper central series of a group is an ascending central series. -/
lemma upper_central_series_is_ascending_central_series :
  is_ascending_central_series (upper_central_series G) :=
⟨rfl, λ x n h, h⟩

/-- A group `G` is nilpotent iff there exists an ascending central series which reaches `G` in
  finitely many steps. -/
theorem nilpotent_iff_finite_ascending_central_series :
  is_nilpotent G ↔ ∃ H : ℕ → subgroup G, is_ascending_central_series H ∧ ∃ n : ℕ, H n = ⊤ :=
begin
  split,
  { intro h,
    use upper_central_series G,
    refine ⟨upper_central_series_is_ascending_central_series G, h.1⟩ },
  { rintro ⟨H, hH, n, hn⟩,
    use n,
    have := ascending_central_series_le_upper H hH n,
    rw hn at this,
    exact eq_top_iff.mpr this }
end

/-- A group `G` is nilpotent iff there exists a descending central series which reaches the
  trivial group in a finite time. -/
theorem nilpotent_iff_finite_descending_central_series :
  is_nilpotent G ↔ ∃ H : ℕ → subgroup G, is_descending_central_series H ∧ ∃ n : ℕ, H n = ⊥ :=
begin
  rw nilpotent_iff_finite_ascending_central_series,
  split,
  { rintro ⟨H, ⟨h0, hH⟩, n, hn⟩,
    use (λ m, H (n - m)),
    split,
    { refine ⟨hn, λ x m hx g, _⟩,
      dsimp at hx,
      by_cases hm : n ≤ m,
      { have hnm : n - m = 0 := nat.sub_eq_zero_of_le hm,
        rw [hnm, h0, subgroup.mem_bot] at hx,
        subst hx,
        convert subgroup.one_mem _,
        group },
      { push_neg at hm,
        apply hH,
        convert hx,
        rw nat.sub_succ,
        exact nat.succ_pred_eq_of_pos (nat.sub_pos_of_lt hm) } },
    { use n,
      rwa nat.sub_self } },
  { rintro ⟨H, ⟨h0, hH⟩, n, hn⟩,
    use (λ m, H (n - m)),
    split,
    { refine ⟨hn, λ x m hx g, _⟩,
      dsimp only at hx,
      by_cases hm : n ≤ m,
      { have hnm : n - m = 0 := nat.sub_eq_zero_of_le hm,
        dsimp only,
        rw [hnm, h0],
        exact mem_top _ },
      { push_neg at hm,
        dsimp only,
        convert hH x _ hx g,
        rw nat.sub_succ,
        exact (nat.succ_pred_eq_of_pos (nat.sub_pos_of_lt hm)).symm } },
    { use n,
      rwa nat.sub_self } },
end

/-- The lower central series of a group `G` is a sequence `H n` of subgroups of `G`, defined
  by `H 0` is all of `G` and for `n≥1`, `H (n + 1) = ⁅H n, G⁆` -/
def lower_central_series (G : Type*) [group G] : ℕ → subgroup G
| 0 := ⊤
| (n+1) := ⁅lower_central_series n, ⊤⁆

variable {G}

/-- The lower central series of a group is a descending central series. -/
theorem lower_central_series_is_descending_central_series :
  is_descending_central_series (lower_central_series G) :=
begin
  split, refl,
  intros x n hxn g,
  exact general_commutator_containment _ _ hxn (subgroup.mem_top g),
end

/-- Any descending central series for a group is bounded below by the lower central series. -/
lemma descending_central_series_ge_lower (H : ℕ → subgroup G)
  (hH : is_descending_central_series H) : ∀ n : ℕ, lower_central_series G n ≤ H n
| 0 := hH.1.symm ▸ le_refl ⊤
| (n + 1) := begin
  specialize descending_central_series_ge_lower n,
  apply (general_commutator_le _ _ _).2,
  intros x hx q _,
  exact hH.2 x n (descending_central_series_ge_lower hx) q,
end

/-- A group is nilpotent if and only if its lower central series eventually reaches
  the trivial subgroup. -/
theorem nilpotent_iff_lower_central_series : is_nilpotent G ↔ ∃ n, lower_central_series G n = ⊥ :=
begin
  rw nilpotent_iff_finite_descending_central_series,
  split,
  { rintro ⟨H, ⟨h0, hs⟩, n, hn⟩,
    use n,
    have := descending_central_series_ge_lower H ⟨h0, hs⟩ n,
    rw hn at this,
    exact eq_bot_iff.mpr this },
  { intro h,
    use [lower_central_series G, lower_central_series_is_descending_central_series, h] },
end

-- try the following exercises. First, read the module docstring, and make sure you understand
-- the definitions. Then read the statements of the theorems in the file.
-- Then for a statement below which takes your fancy, try and find a maths proof
-- and then try and find a Lean proof.

--PRD
@[simp] lemma lower_central_series_zero_def : lower_central_series G 0 = ⊤ := rfl

--PRD
lemma mem_lower_central_series_succ_iff {G : Type*} [group G] (n : ℕ) (x : G) :
  x ∈ lower_central_series G (n + 1) ↔
  x ∈ closure {x | ∃ (p ∈ lower_central_series G n) (q ∈ (⊤ : subgroup G)), p * q * p⁻¹ * q⁻¹ = x}
:= begin
  refl,
end

--PRD
instance (n : ℕ) : normal (lower_central_series G n) :=
begin
  induction n,
  { simp [lower_central_series_zero_def, subgroup.top_normal] },
  { haveI := n_ih,
    exact general_commutator_normal (lower_central_series G n_n) ⊤ },
end

--PRD
lemma upper_central_series_mono : monotone (upper_central_series G) :=
  monotone_nat_of_le_succ $ λ n,
begin
  intros x hx y,
  rw [mul_assoc, mul_assoc, ← mul_assoc y x⁻¹ y⁻¹],
  exact mul_mem (upper_central_series G n) hx
    (normal.conj_mem (upper_central_series.subgroup.normal G n) x⁻¹ (inv_mem _ hx) y),
end

--PRD
lemma subsingleton_is_nilpotent (G : Type*) [group G] (hG : subsingleton G) : is_nilpotent G :=
begin
  exact nilpotent_iff_lower_central_series.2 ⟨0, subsingleton.elim ⊤ ⊥⟩,
end

--PRD
-- upper_central_series is functorial with respect to surjections
lemma ucs_functorial_wrt_surjection (G : Type*) [group G] (H : Type*) [group H] (f : G →* H)
(h : function.surjective f) (n : ℕ)
: subgroup.map f (upper_central_series G n) ≤ upper_central_series H n :=
begin
  induction n with d hd,
  { simp [upper_central_series_zero_def] },
  { rintros _ ⟨x, hx : x ∈ upper_central_series G d.succ, rfl⟩ y',
    rcases (h y') with ⟨y, rfl⟩,
    simpa using hd (mem_map_of_mem f (hx y)) }
end

-- buzzard thinks this is antimono/antitone
lemma lower_central_series_antimono (n : ℕ) :
  lower_central_series G n.succ ≤ lower_central_series G n :=
begin
  intros x hx,
  simp only [mem_lower_central_series_succ_iff, exists_prop, mem_top, exists_true_left, true_and]
    at hx,
  refine closure_induction hx _ (subgroup.one_mem _) (@subgroup.mul_mem _ _ _)
    (@subgroup.inv_mem _ _ _),
  rintros y ⟨z, hz, a, ha⟩,
  rw [← ha, mul_assoc, mul_assoc, ← mul_assoc a z⁻¹ a⁻¹],
  exact mul_mem (lower_central_series G n) hz
    (normal.conj_mem (lower_central_series.subgroup.normal n) z⁻¹ (inv_mem _ hz) a),
end


lemma lcs_functorial_wrt_surjection {H : Type*} [group H] (f : G →* H)
(h : function.surjective f) (n : ℕ)
: subgroup.map f (lower_central_series G n) ≤ lower_central_series H n :=
begin
  induction n with d hd,
  { simp [nat.nat_zero_eq_zero] },
  {
    -- might be able to get rid of this rintros i dont seem to use any of it??
    rintros a ⟨x, hx : x ∈ lower_central_series G d.succ, rfl⟩,
    refine closure_induction hx _ _ _ _,
    -- i haven't actually used the induction n hypothesis.. this must be for the last sorry
    { rintros y ⟨a, ha, b, hb⟩,
      apply mem_closure.mpr,
      intros K hK,
      simp only [exists_prop, mem_top, exists_true_left, true_and] at hK,

      -- i have closure in the goal again...
      sorry,
    },
    { simp [f.map_one, subgroup.one_mem _] },
    { intros y z hy hz,
      simp [monoid_hom.map_mul, subgroup.mul_mem _ hy hz] },
    { intros y hy,
      simp [f.map_inv, subgroup.inv_mem _ hy] } }
end

example (G : Type*) [group G] (hG : is_nilpotent (quotient_group.quotient (center G))) :
  is_nilpotent G :=
begin
  rw nilpotent_iff_lower_central_series at *,
  rcases hG with ⟨n, hG⟩,
  use n + 1,
  ext x,
  split,
  {
    have h0: map (mk' (center G)) (lower_central_series G n) ≤
        lower_central_series (quotient (center G)) n, {
      exact lcs_functorial_wrt_surjection (quotient_group.mk' _) (quot.exists_rep) n,
    },
    have h1 : map (mk' (center G)) (lower_central_series G n) = ⊥, {
      refine eq_bot_mono h0 hG,
    },
    have h4 : mk' (center G) x = 1, {
      apply mem_bot.mp,
      sorry,
    },
    have h2 : ∀ g ∈ lower_central_series G n, g ∈ center G, {
      intros x hx,
      -- follows from functorial of lcs
      sorry,
    },
    have h3 : ∀ x g : G, g ∈ lower_central_series G n → g * x * g⁻¹ * x⁻¹ = 1, {
      intros x g hg,
      rw [mul_inv_eq_one, mul_inv_eq_iff_eq_mul],
      exact (h2 g hg x).symm,
    },
    intro hx,
    rw mem_lower_central_series_succ_iff at hx,
    convert hx,
    symmetry,
    rw closure_eq_bot_iff,
    rintro x ⟨p, hp, q, -, rfl⟩,
    exact set.mem_singleton_iff.mpr (h3 _ _ hp),
  },
  { intro h,
    rw mem_bot at h,
    simp only [h, one_mem] },
end

example (G H : Type*) [group G] [group H] (f : G →* H) (hf1 : f.ker ≤ center G) (hH : is_nilpotent H) :
  is_nilpotent G :=
begin
  sorry,
end


example (G : Type*) [group G] (H : subgroup G) : is_nilpotent G → is_nilpotent H :=
begin
  -- intro hG,
  -- rw nilpotent_iff_lower_central_series at *,
  -- -- have g : ∀ i : ℕ, (lower_central_series H i) ≤ lower_central_series G i, {
  -- --   sorry,
  -- -- },
  -- have h : ∀ i : ℕ, lower_central_series G i = ⊥ → ∃ n : ℕ, lower_central_series H n = ⊥, {
  --   intros x hx,
  --   use x,
  --   -- apply eq_bot_mono _ hx,
  --   sorry,
  -- },
  -- exact exists.elim hG h,
  sorry,
end

example (G H : Type*) [group G] [group H] : is_nilpotent G → is_nilpotent H → is_nilpotent (G × H) :=
begin
  sorry,
end

universe u
example (ι : Type*) [fintype ι] (f : ι → Type u) [∀ i, group (f i)] (h : ∀ i, is_nilpotent (f i)) :
  is_nilpotent (Π i, f i) := sorry

example (G : Type*) [group G] (N : subgroup G) [N.normal] (hG : is_nilpotent G) :
  is_nilpotent (quotient_group.quotient N) :=
begin
  -- type of subgroup.map (quotient_group.mk' (center G)) (center G) is subgroup (quotient (center G))
  -- have h : subgroup.map (quotient_group.mk' (center G)) (center G) ≤ quotient_group.quotient (center G), {
  --   sorry,
  -- },
  sorry,
end

example (G H : Type*) [group G] [group H] (e : G ≃* H) (hG : is_nilpotent G) : is_nilpotent H :=
sorry

-- i think these may not be true or at least not provable with the current defs
-- i think the def of ascending isn't strong enough to prove this
lemma ascending_series_mono {H : ℕ → subgroup G} (hH : is_ascending_central_series H) :
  monotone H := monotone_nat_of_le_succ $ λ n,
begin
  induction n with d hd,
  { simp [hH.1] },
  { rcases hH with ⟨h0, h1⟩,
    intros x hx,

    sorry,
  }
  -- rcases hH with ⟨h0, h1⟩,
  -- intros x hx,
end

-- i think the def of descending isn't strong enough to prove this
lemma descending_series_antimono {H : ℕ → subgroup G} (n : ℕ) (hH : is_descending_central_series H) :
  H n.succ ≤ H n :=
begin
  rcases hH with ⟨h0, hn⟩,
  intros x hx,
  sorry,
end

-- abelian → nilpotent
-- how does abelian work in Lean ??


-- any nilpotent subgroup is normal
-- find out why this doesn't compile!
-- instance {J : subgroup G} [is_nilpotent G] : normal H :=
-- begin
--   sorry,
-- end
