/-
Copyright (c) 2021 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen
-/
import number_theory.class_number.admissible_absolute_value
import analysis.special_functions.pow
import ring_theory.ideal.local_ring
import data.polynomial.degree.card_pow_degree

/-!
# Admissible absolute values on polynomials
This file defines an admissible absolute value
`polynomial.card_pow_degree_is_admissible` which we use to show the class number
of the ring of integers of a function field is finite.

## Main results

* `polynomial.card_pow_degree_is_admissible` shows `card_pow_degree`,
  mapping `p : polynomial ð½_q` to `q ^ degree p`, is admissible
-/

namespace polynomial

open absolute_value real

variables {Fq : Type*} [field Fq] [fintype Fq]

/-- If `A` is a family of enough low-degree polynomials over a finite field, there is a
pair of equal elements in `A`. -/
lemma exists_eq_polynomial {d : â} {m : â} (hm : fintype.card Fq ^ d â¤ m) (b : polynomial Fq)
  (hb : nat_degree b â¤ d) (A : fin m.succ â polynomial Fq) (hA : â i, degree (A i) < degree b) :
  â iâ iâ, iâ â  iâ â§ A iâ = A iâ :=
begin
  -- Since there are > q^d elements of A, and only q^d choices for the highest `d` coefficients,
  -- there must be two elements of A with the same coefficients at
  -- `0`, ... `degree b - 1` â¤ `d - 1`.
  -- In other words, the following map is not injective:
  set f : fin m.succ â (fin d â Fq) := Î» i j, (A i).coeff j,
  have : fintype.card (fin d â Fq) < fintype.card (fin m.succ),
  { simpa using lt_of_le_of_lt hm (nat.lt_succ_self m) },
  -- Therefore, the differences have all coefficients higher than `deg b - d` equal.
  obtain â¨iâ, iâ, i_ne, i_eqâ© := fintype.exists_ne_map_eq_of_card_lt f this,
  use [iâ, iâ, i_ne],
  ext j,
  -- The coefficients higher than `deg b` are the same because they are equal to 0.
  by_cases hbj : degree b â¤ j,
  { rw [coeff_eq_zero_of_degree_lt (lt_of_lt_of_le (hA _) hbj),
        coeff_eq_zero_of_degree_lt (lt_of_lt_of_le (hA _) hbj)] },
  -- So we only need to look for the coefficients between `0` and `deg b`.
  rw not_le at hbj,
  apply congr_fun i_eq.symm â¨j, _â©,
  exact lt_of_lt_of_le (coe_lt_degree.mp hbj) hb
end

/-- If `A` is a family of enough low-degree polynomials over a finite field,
there is a pair of elements in `A` (with different indices but not necessarily
distinct), such that their difference has small degree. -/
lemma exists_approx_polynomial_aux {d : â} {m : â} (hm : fintype.card Fq ^ d â¤ m)
  (b : polynomial Fq) (A : fin m.succ â polynomial Fq) (hA : â i, degree (A i) < degree b) :
  â iâ iâ, iâ â  iâ â§ degree (A iâ - A iâ) < â(nat_degree b - d) :=
begin
  have hb : b â  0,
  { rintro rfl,
    specialize hA 0,
    rw degree_zero at hA,
    exact not_lt_of_le bot_le hA },
  -- Since there are > q^d elements of A, and only q^d choices for the highest `d` coefficients,
  -- there must be two elements of A with the same coefficients at
  -- `degree b - 1`, ... `degree b - d`.
  -- In other words, the following map is not injective:
  set f : fin m.succ â (fin d â Fq) := Î» i j, (A i).coeff (nat_degree b - j.succ),
  have : fintype.card (fin d â Fq) < fintype.card (fin m.succ),
  { simpa using lt_of_le_of_lt hm (nat.lt_succ_self m) },
  -- Therefore, the differences have all coefficients higher than `deg b - d` equal.
  obtain â¨iâ, iâ, i_ne, i_eqâ© := fintype.exists_ne_map_eq_of_card_lt f this,
  use [iâ, iâ, i_ne],
  refine (degree_lt_iff_coeff_zero _ _).mpr (Î» j hj, _),
  -- The coefficients higher than `deg b` are the same because they are equal to 0.
  by_cases hbj : degree b â¤ j,
  { refine coeff_eq_zero_of_degree_lt (lt_of_lt_of_le _ hbj),
    exact lt_of_le_of_lt (degree_sub_le _ _) (max_lt (hA _) (hA _)) },
  -- So we only need to look for the coefficients between `deg b - d` and `deg b`.
  rw [coeff_sub, sub_eq_zero],
  rw [not_le, degree_eq_nat_degree hb, with_bot.coe_lt_coe] at hbj,
  have hj : nat_degree b - j.succ < d,
  { by_cases hd : nat_degree b < d,
    { exact lt_of_le_of_lt tsub_le_self hd },
    { rw not_lt at hd,
      have := lt_of_le_of_lt hj (nat.lt_succ_self j),
      rwa [tsub_lt_iff_tsub_lt hd hbj] at this } },
  have : j = b.nat_degree - (nat_degree b - j.succ).succ,
  { rw [â nat.succ_sub hbj, nat.succ_sub_succ, tsub_tsub_cancel_of_le hbj.le] },
  convert congr_fun i_eq.symm â¨nat_degree b - j.succ, hjâ©
end

/-- If `A` is a family of enough low-degree polynomials over a finite field,
there is a pair of elements in `A` (with different indices but not necessarily
distinct), such that the difference of their remainders is close together. -/
lemma exists_approx_polynomial {b : polynomial Fq} (hb : b â  0)
  {Îµ : â} (hÎµ : 0 < Îµ)
  (A : fin (fintype.card Fq ^ â- log Îµ / log (fintype.card Fq)ââ).succ â polynomial Fq) :
  â iâ iâ, iâ â  iâ â§ (card_pow_degree (A iâ % b - A iâ % b) : â) < card_pow_degree b â¢ Îµ :=
begin
  have hbÎµ : 0 < card_pow_degree b â¢ Îµ,
  { rw [algebra.smul_def, ring_hom.eq_int_cast],
    exact mul_pos (int.cast_pos.mpr (absolute_value.pos _ hb)) hÎµ },
  have one_lt_q : 1 < fintype.card Fq := fintype.one_lt_card,
  have one_lt_q' : (1 : â) < fintype.card Fq, { assumption_mod_cast },
  have q_pos : 0 < fintype.card Fq, { linarith },
  have q_pos' : (0 : â) < fintype.card Fq, { assumption_mod_cast },
  -- If `b` is already small enough, then the remainders are equal and we are done.
  by_cases le_b : b.nat_degree â¤ â- log Îµ / log (fintype.card Fq)ââ,
  { obtain â¨iâ, iâ, i_ne, mod_eqâ© := exists_eq_polynomial le_rfl b le_b (Î» i, A i % b)
      (Î» i, euclidean_domain.mod_lt (A i) hb),
    refine â¨iâ, iâ, i_ne, _â©,
    simp only at mod_eq,
    rwa [mod_eq, sub_self, absolute_value.map_zero, int.cast_zero] },
  -- Otherwise, it suffices to choose two elements whose difference is of small enough degree.
  rw not_le at le_b,
  obtain â¨iâ, iâ, i_ne, deg_ltâ© := exists_approx_polynomial_aux le_rfl b (Î» i, A i % b)
    (Î» i, euclidean_domain.mod_lt (A i) hb),
  simp only at deg_lt,
  use [iâ, iâ, i_ne],
  -- Again, if the remainders are equal we are done.
  by_cases h : A iâ % b = A iâ % b,
  { rwa [h, sub_self, absolute_value.map_zero, int.cast_zero] },
  have h' : A iâ % b - A iâ % b â  0 := mt sub_eq_zero.mp h,
  -- If the remainders are not equal, we'll show their difference is of small degree.
  -- In particular, we'll show the degree is less than the following:
  suffices : (nat_degree (A iâ % b - A iâ % b) : â) <
    b.nat_degree + log Îµ / log (fintype.card Fq),
  { rwa [â real.log_lt_log_iff (int.cast_pos.mpr (card_pow_degree.pos h')) hbÎµ,
        card_pow_degree_nonzero _ h', card_pow_degree_nonzero _ hb,
        algebra.smul_def, ring_hom.eq_int_cast,
        int.cast_pow, int.cast_coe_nat, int.cast_pow, int.cast_coe_nat,
        log_mul (pow_ne_zero _ q_pos'.ne') hÎµ.ne',
        â rpow_nat_cast, â rpow_nat_cast, log_rpow q_pos', log_rpow q_pos',
        â lt_div_iff (log_pos one_lt_q'), add_div, mul_div_cancel _ (log_pos one_lt_q').ne'] },
  -- And that result follows from manipulating the result from `exists_approx_polynomial_aux`
  -- to turn the `-â-stuffââ` into `+ stuff`.
  refine lt_of_lt_of_le (nat.cast_lt.mpr (with_bot.coe_lt_coe.mp _)) _,
  swap, { convert deg_lt, rw degree_eq_nat_degree h' },
  rw [â sub_neg_eq_add, neg_div],
  refine le_trans _ (sub_le_sub_left (nat.le_ceil _) (b.nat_degree : â)),
  rw â neg_div,
  exact le_of_eq (nat.cast_sub le_b.le)
end

/-- If `x` is close to `y` and `y` is close to `z`, then `x` and `z` are at least as close. -/
lemma card_pow_degree_anti_archimedean {x y z : polynomial Fq} {a : â¤}
  (hxy : card_pow_degree (x - y) < a) (hyz : card_pow_degree (y - z) < a) :
  card_pow_degree (x - z) < a :=
begin
  have ha : 0 < a := lt_of_le_of_lt (absolute_value.nonneg _ _) hxy,
  by_cases hxy' : x = y,
  { rwa hxy' },
  by_cases hyz' : y = z,
  { rwa â hyz' },
  by_cases hxz' : x = z,
  { rwa [hxz', sub_self, absolute_value.map_zero] },
  rw [â ne.def, â sub_ne_zero] at hxy' hyz' hxz',
  refine lt_of_le_of_lt _ (max_lt hxy hyz),
  rw [card_pow_degree_nonzero _ hxz', card_pow_degree_nonzero _ hxy',
      card_pow_degree_nonzero _ hyz'],
  have : (1 : â¤) â¤ fintype.card Fq, { exact_mod_cast (@fintype.one_lt_card Fq _ _).le },
  simp only [int.cast_pow, int.cast_coe_nat, le_max_iff],
  refine or.imp (pow_le_pow this) (pow_le_pow this) _,
  rw [nat_degree_le_iff_degree_le, nat_degree_le_iff_degree_le, â le_max_iff,
      â degree_eq_nat_degree hxy', â degree_eq_nat_degree hyz'],
  convert degree_add_le (x - y) (y - z) using 2,
  exact (sub_add_sub_cancel _ _ _).symm
end

/-- A slightly stronger version of `exists_partition` on which we perform induction on `n`:
for all `Îµ > 0`, we can partition the remainders of any family of polynomials `A`
into equivalence classes, where the equivalence(!) relation is "closer than `Îµ`". -/
lemma exists_partition_polynomial_aux (n : â) {Îµ : â} (hÎµ : 0 < Îµ)
  {b : polynomial Fq} (hb : b â  0) (A : fin n â polynomial Fq) :
  â (t : fin n â fin (fintype.card Fq ^ â- log Îµ / log (fintype.card Fq)ââ)),
  â (iâ iâ : fin n),
  t iâ = t iâ â (card_pow_degree (A iâ % b - A iâ % b) : â) < card_pow_degree b â¢ Îµ :=
begin
  have hbÎµ : 0 < card_pow_degree b â¢ Îµ,
  { rw [algebra.smul_def, ring_hom.eq_int_cast],
    exact mul_pos (int.cast_pos.mpr (absolute_value.pos _ hb)) hÎµ },
  -- We go by induction on the size `A`.
  induction n with n ih,
  { refine â¨fin_zero_elim, fin_zero_elimâ© },

  -- Show `anti_archimedean` also holds for real distances.
  have anti_archim' : â {i j k} {Îµ : â}, (card_pow_degree (A i % b - A j % b) : â) < Îµ â
    (card_pow_degree (A j % b - A k % b) : â) < Îµ â (card_pow_degree (A i % b - A k % b) : â) < Îµ,
  { intros i j k Îµ,
    simp_rw [â int.lt_ceil],
    exact card_pow_degree_anti_archimedean },

  obtain â¨t', ht'â© := ih (fin.tail A),
  -- We got rid of `A 0`, so determine the index `j` of the partition we'll re-add it to.
  suffices : â j,
    â i, t' i = j â (card_pow_degree (A 0 % b - A i.succ % b) : â) < card_pow_degree b â¢ Îµ,
  { obtain â¨j, hjâ© := this,
    refine â¨fin.cons j t', Î» iâ iâ, _â©,
    refine fin.cases _ (Î» iâ, _) iâ; refine fin.cases _ (Î» iâ, _) iâ,
    { simpa using hbÎµ },
    { rw [fin.cons_succ, fin.cons_zero, eq_comm, absolute_value.map_sub],
      exact hj iâ },
    { rw [fin.cons_succ, fin.cons_zero],
      exact hj iâ },
    { rw [fin.cons_succ, fin.cons_succ],
      exact ht' iâ iâ } },
  -- `exists_approx_polynomial` guarantees that we can insert `A 0` into some partition `j`,
  -- but not that `j` is uniquely defined (which is needed to keep the induction going).
  obtain â¨j, hjâ© : â j, â (i : fin n), t' i = j â
    (card_pow_degree (A 0 % b - A i.succ % b) : â) < card_pow_degree b â¢ Îµ,
  { by_contra this, push_neg at this,
    obtain â¨jâ, jâ, j_ne, approxâ© := exists_approx_polynomial hb hÎµ
      (fin.cons (A 0) (Î» j, A (fin.succ (classical.some (this j))))),
    revert j_ne approx,
    refine fin.cases _ (Î» jâ, _) jâ; refine fin.cases (Î» j_ne approx, _) (Î» jâ j_ne approx, _) jâ,
    { exact absurd rfl j_ne },
    { rw [fin.cons_succ, fin.cons_zero, â not_le, absolute_value.map_sub] at approx,
      have := (classical.some_spec (this jâ)).2,
      contradiction },
    { rw [fin.cons_succ, fin.cons_zero, â not_le] at approx,
      have := (classical.some_spec (this jâ)).2,
      contradiction },
    { rw [fin.cons_succ, fin.cons_succ] at approx,
      rw [ne.def, fin.succ_inj] at j_ne,
      have : jâ = jâ :=
        (classical.some_spec (this jâ)).1.symm.trans
        (((ht' (classical.some (this jâ)) (classical.some (this jâ))).mpr approx).trans
        (classical.some_spec (this jâ)).1),
      contradiction } },
  -- However, if one of those partitions `j` is inhabited by some `i`, then this `j` works.
  by_cases exists_nonempty_j : â j, (â i, t' i = j) â§
    â i, t' i = j â (card_pow_degree (A 0 % b - A i.succ % b) : â) < card_pow_degree b â¢ Îµ,
  { obtain â¨j, â¨i, hiâ©, hjâ© := exists_nonempty_j,
    refine â¨j, Î» i', â¨hj i', Î» hi', trans ((ht' _ _).mpr _) hiâ©â©,
    apply anti_archim' _ hi',
    rw absolute_value.map_sub,
    exact hj _ hi },
  -- And otherwise, we can just take any `j`, since those are empty.
  refine â¨j, Î» i, â¨hj i, Î» hi, _â©â©,
  have := exists_nonempty_j â¨t' i, â¨i, rflâ©, Î» i' hi', anti_archim' hi ((ht' _ _).mp hi')â©,
  contradiction
end

/-- For all `Îµ > 0`, we can partition the remainders of any family of polynomials `A`
into classes, where all remainders in a class are close together. -/
lemma exists_partition_polynomial (n : â) {Îµ : â} (hÎµ : 0 < Îµ)
  {b : polynomial Fq} (hb : b â  0) (A : fin n â polynomial Fq) :
  â (t : fin n â fin (fintype.card Fq ^ â- log Îµ / log (fintype.card Fq)ââ)),
    â (iâ iâ : fin n), t iâ = t iâ â
      (card_pow_degree (A iâ % b - A iâ % b) : â) < card_pow_degree b â¢ Îµ :=
begin
  obtain â¨t, htâ© := exists_partition_polynomial_aux n hÎµ hb A,
  exact â¨t, Î» iâ iâ hi, (ht iâ iâ).mp hiâ©
end

/-- `Î» p, fintype.card Fq ^ degree p` is an admissible absolute value.
We set `q ^ degree 0 = 0`. -/
noncomputable def card_pow_degree_is_admissible :
  is_admissible (card_pow_degree : absolute_value (polynomial Fq) â¤) :=
{ card := Î» Îµ, fintype.card Fq ^ â- log Îµ / log (fintype.card Fq)ââ,
  exists_partition' := Î» n Îµ hÎµ b hb, exists_partition_polynomial n hÎµ hb,
  .. @card_pow_degree_is_euclidean Fq _ _ }

end polynomial
