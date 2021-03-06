/-
Copyright (c) 2021 Kalle KytΓΆlΓ€. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kalle KytΓΆlΓ€
-/
import topology.algebra.module

/-!
# Weak dual topology

This file defines the weak-* topology on duals of suitable topological modules `E` over suitable
topological semirings `π`. The (weak) dual consists of continuous linear functionals `E βL[π] π`
from `E` to scalars `π`. The weak-* topology is the coarsest topology on this dual
`weak_dual π E := (E βL[π] π)` w.r.t. which the evaluation maps at all `z : E` are continuous.

The weak dual is a module over `π` if the semiring `π` is commutative.

## Main definitions

The main definitions are the type `weak_dual π E` and a topology instance on it.

* `weak_dual π E` is a type synonym for `dual π E` (when the latter is defined): both are equal to
  the type `E βL[π] π` of continuous linear maps from a module `E` over `π` to the ring `π`.
* The instance `weak_dual.topological_space` is the weak-* topology on `weak_dual π E`, i.e., the
  coarsest topology making the evaluation maps at all `z : E` continuous.

## Main results

We establish that `weak_dual π E` has the following structure:
* `weak_dual.has_continuous_add`: The addition in `weak_dual π E` is continuous.
* `weak_dual.module`: If the scalars `π` are a commutative semiring, then `weak_dual π E` is a
  module over `π`.
* `weak_dual.has_continuous_smul`: If the scalars `π` are a commutative semiring, then the scalar
  multiplication by `π` in `weak_dual π E` is continuous.

We prove the following results characterizing the weak-* topology:
* `weak_dual.eval_continuous`: For any `z : E`, the evaluation mapping `weak_dual π E β π` taking
  `x'`to `x' z` is continuous.
* `weak_dual.continuous_of_continuous_eval`: For a mapping to `weak_dual π E` to be continuous,
  it suffices that its compositions with evaluations at all points `z : E` are continuous.
* `weak_dual.tendsto_iff_forall_eval_tendsto`: Convergence in `weak_dual π E` can be characterized
  in terms of convergence of the evaluations at all points `z : E`.

## Notations

No new notation is introduced.

## Implementation notes

The weak-* topology is defined as the induced topology under the mapping that associates to a dual
element `x'` the functional `E β π`, when the space `E β π` of functionals is equipped with the
topology of pointwise convergence (product topology).

Typically one might assume that `π` is a topological semiring in the sense of the typeclasses
`topological_space π`, `semiring π`, `has_continuous_add π`, `has_continuous_mul π`,
and that the space `E` is a topological module over `π` in the sense of the typeclasses
`topological_space E`, `add_comm_monoid E`, `has_continuous_add E`, `module π E`,
`has_continuous_smul π E`. The definitions and results are, however, given with weaker assumptions
when possible.

## References

* https://en.wikipedia.org/wiki/Weak_topology#Weak-*_topology

## Tags

weak-star, weak dual

-/

noncomputable theory
open filter
open_locale topological_space

universes u v

section weak_star_topology
/-!
### Weak star topology on duals of topological modules
-/

variables (π : Type*) [topological_space π] [semiring π]
variables (E : Type*) [topological_space E] [add_comm_monoid E] [module π E]

/-- The weak dual of a topological module `E` over a topological semiring `π` consists of
continuous linear functionals from `E` to scalars `π`. It is a type synonym with the usual dual
(when the latter is defined), but will be equipped with a different topology. -/
@[derive [inhabited, Ξ» Ξ±, has_coe_to_fun Ξ± (Ξ» _, E β π)]]
def weak_dual := E βL[π] π

instance [has_continuous_add π] : add_comm_monoid (weak_dual π E) :=
continuous_linear_map.add_comm_monoid

namespace weak_dual

/-- The weak-* topology instance `weak_dual.topological_space` on the dual of a topological module
`E` over a topological semiring `π` is defined as the induced topology under the mapping that
associates to a dual element `x' : weak_dual π E` the functional `E β π`, when the space `E β π`
of functionals is equipped with the topology of pointwise convergence (product topology). -/
instance : topological_space (weak_dual π E) :=
topological_space.induced (Ξ» x' : weak_dual π E, Ξ» z : E, x' z) Pi.topological_space

lemma coe_fn_continuous :
  continuous (Ξ» (x' : (weak_dual π E)), (Ξ» (z : E), x' z)) :=
continuous_induced_dom

lemma eval_continuous (z : E) : continuous (Ξ» (x' : weak_dual π E), x' z) :=
(continuous_pi_iff.mp (coe_fn_continuous π E)) z

lemma continuous_of_continuous_eval {Ξ± : Type u} [topological_space Ξ±]
  {g : Ξ± β weak_dual π E} (h : β z, continuous (Ξ» a, g a z)) : continuous g :=
continuous_induced_rng (continuous_pi_iff.mpr h)

theorem tendsto_iff_forall_eval_tendsto {Ξ³ : Type u} {F : filter Ξ³}
  {Οs : Ξ³ β weak_dual π E} {Ο : weak_dual π E} :
  tendsto Οs F (π Ο) β β z : E, tendsto (Ξ» i, Οs i z) F (π (Ο z)) :=
begin
  rw β tendsto_pi_nhds,
  split,
  { intros weak_star_conv,
    exact (((coe_fn_continuous π E).tendsto Ο).comp weak_star_conv), },
  { intro h_lim_forall,
    rwa [nhds_induced, tendsto_comap_iff], },
end

/-- Addition in `weak_dual π E` is continuous. -/
instance [has_continuous_add π] : has_continuous_add (weak_dual π E) :=
{ continuous_add := begin
    apply continuous_of_continuous_eval,
    intros z,
    have h : continuous (Ξ» p : π Γ π, p.1 + p.2) := continuous_add,
    exact h.comp ((eval_continuous π E z).prod_map (eval_continuous π E z)),
  end, }

/-- If the scalars `π` are a commutative semiring, then `weak_dual π E` is a module over `π`. -/
instance (π : Type u) [topological_space π] [comm_semiring π]
  [has_continuous_add π] [has_continuous_mul π]
  (E : Type*) [topological_space E] [add_comm_group E] [module π E] :
  module π (weak_dual π E) :=
continuous_linear_map.module

/-- Scalar multiplication in `weak_dual π E` is continuous (when `π` is a commutative
semiring). -/
instance (π : Type u) [topological_space π] [comm_semiring π]
  [has_continuous_add π] [has_continuous_mul π]
  (E : Type*) [topological_space E] [add_comm_group E]
  [module π E] :
  has_continuous_smul π (weak_dual π E) :=
{ continuous_smul := begin
    apply continuous_of_continuous_eval,
    intros z,
    have h : continuous (Ξ» p : π Γ π, p.1 * p.2) := continuous_mul,
    exact h.comp ((continuous_id').prod_map (eval_continuous π E z)),
  end, }

end weak_dual

end weak_star_topology
