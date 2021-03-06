/-
Copyright (c) 2019 SΓ©bastien GouΓ«zel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: SΓ©bastien GouΓ«zel
-/
import analysis.normed_space.multilinear

/-!
# Formal multilinear series

In this file we define `formal_multilinear_series π E F` to be a family of `n`-multilinear maps for
all `n`, designed to model the sequence of derivatives of a function. In other files we use this
notion to define `C^n` functions (called `times_cont_diff` in `mathlib`) and analytic functions.

## Notations

We use the notation `E [Γn]βL[π] F` for the space of continuous multilinear maps on `E^n` with
values in `F`. This is the space in which the `n`-th derivative of a function from `E` to `F` lives.

## Tags

multilinear, formal series
-/

noncomputable theory

open set fin
open_locale topological_space

variables {π : Type*} [nondiscrete_normed_field π]
{E : Type*} [normed_group E] [normed_space π E]
{F : Type*} [normed_group F] [normed_space π F]
{G : Type*} [normed_group G] [normed_space π G]

/-- A formal multilinear series over a field `π`, from `E` to `F`, is given by a family of
multilinear maps from `E^n` to `F` for all `n`. -/
@[derive add_comm_group]
def formal_multilinear_series
  (π : Type*) [nondiscrete_normed_field π]
  (E : Type*) [normed_group E] [normed_space π E]
  (F : Type*) [normed_group F] [normed_space π F] :=
Ξ  (n : β), (E [Γn]βL[π] F)

instance : inhabited (formal_multilinear_series π E F) := β¨0β©

section module
/- `derive` is not able to find the module structure, probably because Lean is confused by the
dependent types. We register it explicitly. -/
local attribute [reducible] formal_multilinear_series

instance : module π (formal_multilinear_series π E F) :=
begin
  letI : β n, module π (continuous_multilinear_map π (Ξ» (i : fin n), E) F) :=
    Ξ» n, by apply_instance,
  apply_instance
end

end module

namespace formal_multilinear_series

variables (p : formal_multilinear_series π E F)

/-- Forgetting the zeroth term in a formal multilinear series, and interpreting the following terms
as multilinear maps into `E βL[π] F`. If `p` corresponds to the Taylor series of a function, then
`p.shift` is the Taylor series of the derivative of the function. -/
def shift : formal_multilinear_series π E (E βL[π] F) :=
Ξ»n, (p n.succ).curry_right

/-- Adding a zeroth term to a formal multilinear series taking values in `E βL[π] F`. This
corresponds to starting from a Taylor series for the derivative of a function, and building a Taylor
series for the function itself. -/
def unshift (q : formal_multilinear_series π E (E βL[π] F)) (z : F) :
  formal_multilinear_series π E F
| 0       := (continuous_multilinear_curry_fin0 π E F).symm z
| (n + 1) := continuous_multilinear_curry_right_equiv' π n E F (q n)

/-- Killing the zeroth coefficient in a formal multilinear series -/
def remove_zero (p : formal_multilinear_series π E F) : formal_multilinear_series π E F
| 0       := 0
| (n + 1) := p (n + 1)

@[simp] lemma remove_zero_coeff_zero : p.remove_zero 0 = 0 := rfl

@[simp] lemma remove_zero_coeff_succ (n : β) : p.remove_zero (n+1) = p (n+1) := rfl

lemma remove_zero_of_pos {n : β} (h : 0 < n) : p.remove_zero n = p n :=
by { rw β nat.succ_pred_eq_of_pos h, refl }

/-- Convenience congruence lemma stating in a dependent setting that, if the arguments to a formal
multilinear series are equal, then the values are also equal. -/
lemma congr (p : formal_multilinear_series π E F) {m n : β} {v : fin m β E} {w : fin n β E}
  (h1 : m = n) (h2 : β (i : β) (him : i < m) (hin : i < n), v β¨i, himβ© = w β¨i, hinβ©) :
  p m v = p n w :=
by { cases h1, congr' with β¨i, hiβ©, exact h2 i hi hi }

/-- Composing each term `pβ` in a formal multilinear series with `(u, ..., u)` where `u` is a fixed
continuous linear map, gives a new formal multilinear series `p.comp_continuous_linear_map u`. -/
def comp_continuous_linear_map (p : formal_multilinear_series π F G) (u : E βL[π] F) :
  formal_multilinear_series π E G :=
Ξ» n, (p n).comp_continuous_linear_map (Ξ» (i : fin n), u)

@[simp] lemma comp_continuous_linear_map_apply
  (p : formal_multilinear_series π F G) (u : E βL[π] F) (n : β) (v : fin n β E) :
  (p.comp_continuous_linear_map u) n v = p n (u β v) := rfl

variables (π) {π' : Type*} [nondiscrete_normed_field π'] [normed_algebra π π']
variables [normed_space π' E] [is_scalar_tower π π' E]
variables [normed_space π' F] [is_scalar_tower π π' F]

/-- Reinterpret a formal `π'`-multilinear series as a formal `π`-multilinear series, where `π'` is a
normed algebra over `π`. -/
@[simp] protected def restrict_scalars (p : formal_multilinear_series π' E F) :
  formal_multilinear_series π E F :=
Ξ» n, (p n).restrict_scalars π

end formal_multilinear_series
