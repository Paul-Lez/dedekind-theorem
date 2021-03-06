/-
Copyright (c) 2021 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker
-/
import analysis.normed_space.ordered
import analysis.asymptotics.asymptotics

/-!
# A collection of specific asymptotic results

This file contains specific lemmas about asymptotics which don't have their place in the general
theory developped in `analysis.asymptotics.asymptotics`.
-/

open filter asymptotics
open_locale topological_space

section linear_ordered_field

variables {๐ : Type*} [linear_ordered_field ๐]

lemma pow_div_pow_eventually_eq_at_top {p q : โ} :
  (ฮป x : ๐, x^p / x^q) =แถ [at_top] (ฮป x, x^((p : โค) -q)) :=
begin
  apply ((eventually_gt_at_top (0 : ๐)).mono (ฮป x hx, _)),
  simp [zpow_subโ hx.ne'],
end

lemma pow_div_pow_eventually_eq_at_bot {p q : โ} :
  (ฮป x : ๐, x^p / x^q) =แถ [at_bot] (ฮป x, x^((p : โค) -q)) :=
begin
  apply ((eventually_lt_at_bot (0 : ๐)).mono (ฮป x hx, _)),
  simp [zpow_subโ hx.ne'.symm],
end

lemma tendsto_zpow_at_top_at_top {n : โค}
  (hn : 0 < n) : tendsto (ฮป x : ๐, x^n) at_top at_top :=
begin
  lift n to โ using hn.le,
  simp only [zpow_coe_nat],
  exact tendsto_pow_at_top (nat.succ_le_iff.mpr $int.coe_nat_pos.mp hn)
end

lemma tendsto_pow_div_pow_at_top_at_top {p q : โ}
  (hpq : q < p) : tendsto (ฮป x : ๐, x^p / x^q) at_top at_top :=
begin
  rw tendsto_congr' pow_div_pow_eventually_eq_at_top,
  apply tendsto_zpow_at_top_at_top,
  linarith
end

lemma tendsto_pow_div_pow_at_top_zero [topological_space ๐] [order_topology ๐] {p q : โ}
  (hpq : p < q) : tendsto (ฮป x : ๐, x^p / x^q) at_top (๐ 0) :=
begin
  rw tendsto_congr' pow_div_pow_eventually_eq_at_top,
  apply tendsto_zpow_at_top_zero,
  linarith
end

end linear_ordered_field

section normed_linear_ordered_field

variables {๐ : Type*} [normed_linear_ordered_field ๐]

lemma asymptotics.is_o_pow_pow_at_top_of_lt
  [order_topology ๐] {p q : โ} (hpq : p < q) :
  is_o (ฮป x : ๐, x^p) (ฮป x, x^q) at_top :=
begin
  refine (is_o_iff_tendsto' _).mpr (tendsto_pow_div_pow_at_top_zero hpq),
  exact (eventually_gt_at_top 0).mono (ฮป x hx hxq, (pow_ne_zero q hx.ne' hxq).elim),
end

lemma asymptotics.is_O.trans_tendsto_norm_at_top {ฮฑ : Type*} {u v : ฮฑ โ ๐} {l : filter ฮฑ}
  (huv : is_O u v l) (hu : tendsto (ฮป x, โฅu xโฅ) l at_top) : tendsto (ฮป x, โฅv xโฅ) l at_top :=
begin
  rcases huv.exists_pos with โจc, hc, hcuvโฉ,
  rw is_O_with at hcuv,
  convert tendsto.at_top_div_const hc (tendsto_at_top_mono' l hcuv hu),
  ext x,
  rw mul_div_cancel_left _ hc.ne.symm,
end

end normed_linear_ordered_field
