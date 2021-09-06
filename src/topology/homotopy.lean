/-
Copyright (c) 2021 Shing Tak Lam. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shing Tak Lam
-/

import topology.unit_interval
import topology.algebra.ordered.proj_Icc
import topology.continuous_function.basic
import topology.compact_open

/-!
# Homotopy between functions

In this file, we define a `homotopy` between two functions `f₀` and `f₁`.

## Definitions

* `homotopy f₀ f₁` is the type of homotopies between `f₀` and `f₁`
* `homotopy.refl f₀` is the constant homotopy between `f₀` and `f₀`
* `homotopy.symm f₀ f₁` is a `homotopy f₁ f₀` defined by reversing the homotopy
* `homotopy.trans F G`, where `F : homotopy f₀ f₁`, `G : homotopy f₁ f₂` is a `homotopy f₀ f₂`
  defined by putting the first homotopy on `[0, 1/2]` and the second on `[1/2, 1]`.
-/

noncomputable theory

universes u v

variables {X : Type u} {Y : Type v} [topological_space X] [topological_space Y]

open_locale unit_interval

namespace continuous_map

/--
The type of homotopies between two functions.
-/
structure homotopy (f₀ f₁ : X → Y) extends C(I × X, Y) :=
(to_fun_zero : ∀ x, to_fun (0, x) = f₀ x)
(to_fun_one : ∀ x, to_fun (1, x) = f₁ x)

namespace homotopy

section

variables {f₀ f₁ : X → Y}

instance : has_coe_to_fun (homotopy f₀ f₁) := ⟨_, λ F, F.to_fun⟩

@[ext]
lemma ext {F G : homotopy f₀ f₁} (h : ∀ x, F x = G x) : F = G :=
begin
  cases F, cases G,
  congr' 1,
  ext x,
  exact h x,
end

@[continuity]
protected lemma continuous (F : homotopy f₀ f₁) : continuous F := F.continuous_to_fun

@[simp]
lemma apply_zero (F : homotopy f₀ f₁) (x : X) : F (0, x) = f₀ x := F.to_fun_zero x
@[simp]
lemma apply_one (F : homotopy f₀ f₁) (x : X) : F (1, x) = f₁ x := F.to_fun_one x

@[simp]
lemma to_continuous_map_apply (F : homotopy f₀ f₁) (k : I × X) : F.to_continuous_map k = F k := rfl

/--
Currying a homotopy
-/
def curry (F : homotopy f₀ f₁) : C(I, C(X, Y)) := F.to_continuous_map.curry

/--
Extending a homotopy to a curried function.
-/
def extend (F : homotopy f₀ f₁) : C(ℝ, C(X, Y)) := F.curry.Icc_extend zero_le_one

@[simp]
lemma extend_apply_zero (F : homotopy f₀ f₁) (x : X) : F.extend 0 x = f₀ x :=
by simp [extend, curry]

@[simp]
lemma extend_apply_one (F : homotopy f₀ f₁) (x : X) : F.extend 1 x = f₁ x := by simp [extend, curry]

end

/--
Given a continuous function `f`, we can define a `homotopy f f` by `F (x, t) = f x`
-/
def refl {f : X → Y} (hf : continuous f) : homotopy f f :=
{ to_fun := λ x, f x.2,
  continuous_to_fun := by continuity,
  to_fun_zero := λ _, rfl,
  to_fun_one := λ _, rfl }

instance : inhabited (homotopy (id : X → X) id) := ⟨homotopy.refl continuous_id⟩

/--
Given a `homotopy f₀ f₁`, we can define a `homotopy f₁ f₀` by reversing the homotopy.
-/
def symm {f₀ f₁ : X → Y} (F : homotopy f₀ f₁) : homotopy f₁ f₀ :=
{ to_fun := λ x, F (σ x.1, x.2),
  continuous_to_fun := by continuity,
  to_fun_zero := by norm_num,
  to_fun_one := by norm_num }

@[simp]
lemma symm_apply {f₀ f₁ : X → Y} (F : homotopy f₀ f₁) (x : X) (t : I) :
  F.symm (t, x) = F (σ t, x) := rfl

/--
Given `homotopy f₀ f₁` and `homotopy f₁ f₂`, we can define a `homotopy f₀ f₂` by putting the first
homotopy on `[0, 1/2]` and the second on `[1/2, 1]`.
-/
def trans {f₀ f₁ f₂ : X → Y} (F : homotopy f₀ f₁) (G : homotopy f₁ f₂) : homotopy f₀ f₂ :=
{ to_fun := λ x, if (x.1 : ℝ) ≤ 1/2 then F.extend (2 * x.1) x.2 else G.extend (2 * x.1 - 1) x.2,
  continuous_to_fun := begin
    refine continuous_if_le _ _ (continuous.continuous_on _) (continuous.continuous_on _) _,
    swap 5,
    { rintros x hx,
      norm_num [hx] },
    exact continuous_induced_dom.comp continuous_fst,
    exact continuous_const,
    -- continuity used to work here...
    continuity,
  end,
  to_fun_zero := λ x, by norm_num,
  to_fun_one := λ x, by norm_num }

end homotopy

end continuous_map