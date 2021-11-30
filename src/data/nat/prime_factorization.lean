/-
Copyright (c) 2021 Stuart Presnell. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Stuart Presnell
-/
import data.nat.prime
import data.nat.mul_ind

/-!
# Prime factorizations

 `n.prime_factorization` is the finitely supported function `ℕ →₀ ℕ`
 mapping each prime factor of `n` to its multiplicity in `n`.  For example, since 2000 = 2^4 * 5^3,
  * `prime_factorization 2000 2` is 4
  * `prime_factorization 2000 5` is 3
  * `prime_factorization 2000 k` is 0 for all other `k : ℕ`.

-/

open nat finset list finsupp
open_locale big_operators

namespace nat

/-- `n.prime_factorization` is the finitely supported function `ℕ →₀ ℕ`
 mapping each prime factor of `n` to its multiplicity in `n`. -/
noncomputable def prime_factorization (n : ℕ) : ℕ →₀ ℕ := (n.factors : multiset ℕ).to_finsupp

lemma prime_factorization_count {n p : ℕ} : n.prime_factorization p = list.count p n.factors :=
by simp [prime_factorization]

/-- Every positive natural number has a unique prime factorization -/
lemma prime_factorization_eq_iff {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
  a.prime_factorization = b.prime_factorization ↔ a = b :=
⟨λ h, eq_of_count_factors_eq ha hb (λ p, by simp [←prime_factorization_count, h]), λ h, by rw h⟩

@[simp] lemma prime_factorization_zero : prime_factorization 0 = 0  :=
by simp [prime_factorization]

@[simp] lemma prime_factorization_one : prime_factorization 1 = 0 :=
by simp [prime_factorization]

/-- The support of `n.prime_factorization` is exactly `n.factors.to_finset` -/
@[simp] lemma support_prime_factorization {n : ℕ} :
  n.prime_factorization.support = n.factors.to_finset :=
by simpa [prime_factorization, multiset.to_finsupp_support]

lemma factor_iff_mem_factorization {n p : ℕ} :
  (p ∈ n.prime_factorization.support) ↔ (p ∈ n.factors) :=
by simp only [support_prime_factorization, list.mem_to_finset]

/-- The only numbers with empty prime factorization are 0 and 1 -/
lemma prime_factorization_eq_nil_iff (n : ℕ) : n.prime_factorization = 0 ↔ n = 0 ∨ n = 1 :=
by simp [prime_factorization, add_equiv.map_eq_zero_iff, multiset.coe_eq_zero]

/-- For prime `p` and `k > 0`, the only prime factor of `p^k` is `p` with multiplicity `k` -/
@[simp] lemma prime_factorization_prime_pos_pow {p k : ℕ} (hp : prime p) (hk : 0 < k) :
  prime_factorization (p^k) = single p k :=
begin
  rw eq_single_iff,
  split,
  { simp only [support_prime_factorization, prime_pow_prime_divisor hk hp, finset.subset.refl] },
  { rw [prime_factorization_count, prime.factors_pow hp k, count_repeat p k] }
end

/-- The only prime factor of prime `p` is `p` itself, with multiplicity 1 -/
@[simp] lemma prime_factorization_prime {p : ℕ} (hp : prime p) :
  p.prime_factorization = single p 1 :=
by simp only [←prime_factorization_prime_pos_pow hp one_pos, pow_one]

end nat