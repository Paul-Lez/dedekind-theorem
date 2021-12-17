import topology.compact_open
import topology.uniform_space.basic
import topology.order

universes u₁ u₂

open_locale filter uniformity topological_space
open uniform_space set

variables {α : Type u₁} {β : Type u₂} [topological_space α] [uniform_space β]
variables (K : set α) (V : set (β × β)) (f : C(α, β))

/-- A neighbourhood system for the topology of compact convergence. -/
def uniform_gen : set C(α, β) := {g | ∀ (x ∈ K), (f x, g x) ∈ V }

/-- A filter basis for the neighbourhood filter of a point in the topology of compact
convergence. -/
def compact_convergence_filter_basis (f : C(α, β)) : filter_basis C(α, β) :=
{ sets       := { m | ∃ (K : set α) (hK : is_compact K) (V ∈ 𝓤 β), m = uniform_gen K V f },
  nonempty   := ⟨univ, ∅, is_compact_empty, univ, filter.univ_mem, by { ext, simp [uniform_gen], }⟩,
  inter_sets :=
    begin
      rintros - - ⟨K₁, hK₁, V₁, hV₁, rfl⟩ ⟨K₂, hK₂, V₂, hV₂, rfl⟩,
      exact ⟨uniform_gen (K₁ ∪ K₂) (V₁ ∩ V₂) f,
        ⟨K₁ ∪ K₂, hK₁.union hK₂, V₁ ∩ V₂, filter.inter_mem hV₁ hV₂, rfl⟩,
        λ g hg, ⟨λ x hx, mem_of_mem_inter_left (hg x (mem_union_left K₂ hx)),
                 λ x hx, mem_of_mem_inter_right (hg x (mem_union_right K₁ hx))⟩⟩,
    end, }

/-- The topology of compact convergence. I claim this topology is induced by a uniform structure,
defined below. -/
def compact_convergence_topology : topological_space C(α, β) :=
topological_space.mk_of_nhds $ λ f, (compact_convergence_filter_basis f).filter

lemma mem_compact_convergence_filter (X : set C(α, β)) :
  X ∈ (compact_convergence_filter_basis f).filter ↔
  ∃ (K : set α) (V : set (β × β)) (hK : is_compact K) (hv : V ∈ 𝓤 β), uniform_gen K V f ⊆ X :=
begin
  split,
  { rintros ⟨s, ⟨K, hK, V, hV, rfl⟩, hX⟩,
    exact ⟨K, V, hK, hV, hX⟩, },
  { rintros ⟨K, V, hK, hV, hX⟩,
    exact ⟨uniform_gen K V f, ⟨K, hK, V, hV, rfl⟩, hX⟩, },
end

lemma mem_uniform_gen_self (hV : V ∈ 𝓤 β) : f ∈ uniform_gen K V f :=
λ x hx, refl_mem_uniformity hV

lemma uniform_gen_mono (V' : set (β × β)) (hV' : V' ⊆ V) :
  uniform_gen K V' f ⊆ uniform_gen K V f :=
λ x hx a ha, hV' (hx a ha)

lemma uniform_gen_comp {g₁ g₂ : C(α, β)} (V' : set (β × β))
  (h₁ : g₁ ∈ uniform_gen K V f) (h₂ : g₂ ∈ uniform_gen K V' g₁) :
  g₂ ∈ uniform_gen K (V ○ V') f :=
λ x hx, ⟨g₁ x, h₁ x hx, h₂ x hx⟩

lemma uniform_gen_nhd_basis (hV : V ∈ 𝓤 β) :
  ∃ (V' ∈ 𝓤 β), V' ⊆ V ∧ ∀ (g ∈ uniform_gen K V' f), uniform_gen K V' g ⊆ uniform_gen K V f :=
begin
  obtain ⟨V', hV'₁, hV'₂⟩ := comp_mem_uniformity_sets hV,
  refine ⟨V', hV'₁, subset.trans (subset_comp_self_of_mem_uniformity hV'₁) hV'₂, λ g hg g' hg', _⟩,
  exact uniform_gen_mono K V f (V' ○ V') hV'₂ (uniform_gen_comp K V' f V' hg hg'),
end

/-- Any point of `compact_open.gen K U` is also an interior point wrt the topology of compact
convergence.

The topology of compact convergence is thus at least as fine as the compact-open topology. -/
lemma uniform_gen_subset_compact_open (hK : is_compact K) {U : set β} (hU : is_open U)
  (hf : f ∈ continuous_map.compact_open.gen K U) :
  ∃ (V ∈ 𝓤 β), is_open V ∧ uniform_gen K V f ⊆ continuous_map.compact_open.gen K U :=
begin
  obtain ⟨V, hV₁, hV₂, hV₃⟩ := lebesgue_number_of_compact_open (hK.image f.continuous) hU hf,
  refine ⟨V, hV₁, hV₂, _⟩,
  rintros g hg - ⟨x, hx, rfl⟩,
  exact hV₃ (f x) ⟨x, hx, rfl⟩ (hg x hx),
end

/-- The point `f` in `uniform_gen K V f` is also an interior point wrt the compact-open topology.

From this it should follow that the compact-open topology is at least as fine as the topology of
compact convergence. -/
lemma Inter_compact_open_gen_subset_uniform_gen (hK : is_compact K) (hV : V ∈ 𝓤 β) :
  ∃ (ι : Sort (u₁ + 1)) [fintype ι]
  (C : ι → set α) (hC : ∀ i, is_compact (C i))
  (U : ι → set β) (hU : ∀ i, is_open (U i)),
  (f ∈ ⋂ i, continuous_map.compact_open.gen (C i) (U i)) ∧
  (⋂ i, continuous_map.compact_open.gen (C i) (U i)) ⊆ uniform_gen K V f :=
begin
  obtain ⟨W, hW₁, hW₄, hW₂, hW₃⟩ := comp_open_symm_mem_uniformity_sets hV,
  obtain ⟨Z, hZ₁, hZ₄, hZ₂, hZ₃⟩ := comp_open_symm_mem_uniformity_sets hW₁,
  let U : α → set α := λ x, f⁻¹' (ball (f x) Z),
  have hU : ∀ x, is_open (U x) := λ x, f.continuous.is_open_preimage _ (is_open_ball _ hZ₄),
  have hUK : K ⊆ ⋃ (x : K), U (x : K),
  { intros x hx,
    simp only [exists_prop, mem_Union, Union_coe_set, mem_preimage],
    use (⟨x, hx⟩ : K),
    simp [hx, mem_ball_self (f x) hZ₁], },
  obtain ⟨t, ht⟩ := hK.elim_finite_subcover _ (λ (x : K), hU x.val) hUK,
  let C : t → set α := λ i, K ∩ closure (U ((i : K) : α)),
  have hC : K ⊆ ⋃ i, C i,
  { rw [← K.inter_Union, subset_inter_iff],
    refine ⟨rfl.subset, ht.trans _⟩,
    simp only [set_coe.forall, subtype.coe_mk, Union_subset_iff],
    intros x hx₁ hx₂,
    apply subset_subset_Union (⟨_, hx₂⟩ : t),
    simp [subset_closure], },
  have hfC : ∀ (i : t), f '' C i ⊆ ball (f ((i : K) : α)) W,
  { rintros ⟨⟨x, hx₁⟩, hx₂⟩,
    calc f '' (K ∩ closure (U x))
          ⊆ f '' (closure (U x)) : by { mono, simp only [inter_subset_right], }
      ... ⊆ closure (f '' (U x)) : continuous_on.image_closure f.continuous.continuous_on
      ... ⊆ closure (ball (f x) Z) : by { mono, simp, }
      ... ⊆ ball (f x) W : by { intros y hy,
                                obtain ⟨z, hz₁,hz₂⟩ := uniform_space.mem_closure_iff_ball.mp hy hZ₁,
                                rw mem_ball_symmetry hZ₂ at hz₁,
                                exact ball_mono hZ₃ _ (mem_ball_comp hz₂ hz₁), }, },
  refine ⟨t,
          t.fintype_coe_sort,
          C,
          λ i, hK.inter_right is_closed_closure,
          λ i, ball (f ((i : K) : α)) W,
          λ i, is_open_ball _ hW₄,
          by simp [continuous_map.compact_open.gen, hfC, -image_subset_iff],
          _⟩,
  intros g hg x hx,
  apply hW₃,
  replace hx := mem_Union.mp (hC hx),
  obtain ⟨y, hy⟩ := hx,
  rw mem_comp_rel,
  use f y,
  simp only [mem_Inter, continuous_map.compact_open.gen, mem_set_of_eq, image_subset_iff] at hg,
  refine ⟨_, mem_preimage.mp (hg y hy)⟩,
  simp only [image_subset_iff, mem_preimage] at hfC,
  specialize hfC y hy,
  rw [ball_eq_of_symmetry hW₂] at hfC,
  exact hfC,
end

/-- This should follow from the various lemmas above. -/
lemma compact_open_eq_uniform :
  (compact_convergence_topology : topological_space C(α, β)) = continuous_map.compact_open :=
begin
  rw [compact_convergence_topology, continuous_map.compact_open],
  refine le_antisymm _ _,
  { rw le_generate_from_iff_subset_is_open,
    simp only [and_imp, exists_prop, forall_exists_index, set_of_subset_set_of],
    rintros - K hK U hU rfl,
    intros f hf,
    obtain ⟨V, hV, hV', hVf⟩ := uniform_gen_subset_compact_open K f hK hU hf,
    exact filter.mem_of_superset (filter_basis.mem_filter_of_mem _ ⟨K, hK, V, hV, rfl⟩) hVf, },
  { intros X hX,
    apply is_open_iff_forall_mem_open.2,
    intros f hf,
    have hXf : X ∈ @nhds C(α, β) compact_convergence_topology f,
    { exact @is_open.mem_nhds C(α, β) compact_convergence_topology _ _ hX hf, },
    rw topological_space.nhds_mk_of_nhds at hXf,
    { obtain ⟨-, ⟨K, hK, V, hV, rfl⟩, hXf⟩ := hXf,
      obtain ⟨ι, hι, C, hC, U, hU, h₁, h₂⟩ := Inter_compact_open_gen_subset_uniform_gen _ _ f hK hV,
      haveI := hι,
      refine ⟨⋂ i, continuous_map.compact_open.gen (C i) (U i), h₂.trans hXf, _, h₁⟩,
      apply is_open_Inter,
      intros i,
      exact continuous_map.is_open_gen (hC i) (hU i), },
    { rintros g Y ⟨-, ⟨K, hK, V, hV, rfl⟩, hY⟩,
      exact hY (mem_uniform_gen_self K V g hV), },
    { rintros g Y ⟨-, ⟨K, hK, V, hV, rfl⟩, hY⟩,
      obtain ⟨V', hV', hV'', hV'''⟩ := uniform_gen_nhd_basis K V g hV,
      refine ⟨uniform_gen K V' g, filter_basis.mem_filter_of_mem _ ⟨K, hK, V', hV', rfl⟩, _, _⟩,
      { exact set.subset.trans (uniform_gen_mono K V g V' hV'') hY, },
      { intros g' hg',
        rw filter_basis.mem_filter_iff,
        refine ⟨uniform_gen K V' g', ⟨K, hK, V', hV', rfl⟩, _⟩,
        refine set.subset.trans _ hY,
        apply hV''',
        exact hg', }, }, },
end

def compact_convergence_uniformity : filter (C(α, β) × C(α, β)) :=
⨅ KV ∈ { KV : set α × set (β × β) | is_compact KV.1 ∧ KV.2 ∈ 𝓤 β },
𝓟 { fg : C(α, β) × C(α, β) | ∀ (x : α), x ∈ KV.1 → (fg.1 x, fg.2 x) ∈ KV.2 }

lemma mem_compact_convergence_uniformity (X : set (C(α, β) × C(α, β))) :
  X ∈ @compact_convergence_uniformity α β _ _ ↔
  ∃ (K : set α) (V : set (β × β)) (hK : is_compact K) (hV : V ∈ 𝓤 β),
    { fg : C(α, β) × C(α, β) | ∀ (x : α), x ∈ K → (fg.1 x, fg.2 x) ∈ V } ⊆ X :=
begin
  simp only [compact_convergence_uniformity],
  have h : { KV : set α × set (β × β) | is_compact KV.1 ∧ KV.2 ∈ 𝓤 β }.nonempty,
  { exact ⟨⟨∅, univ⟩, is_compact_empty, filter.univ_mem⟩, },
  rw (filter.has_basis_binfi_principal _ h).mem_iff,
  { simp only [exists_prop, prod.forall, set_of_subset_set_of, mem_set_of_eq, prod.exists],
    split,
    { rintros ⟨K, V, ⟨hK, hV⟩, hX⟩,
      exact ⟨K, V, hK, hV, hX⟩, },
    { rintros ⟨K, V, hK, hV, hX⟩,
      exact ⟨K, V, ⟨hK, hV⟩, hX⟩, }, },
  { rintros ⟨K₁, V₁⟩ ⟨hK₁ : is_compact K₁, hV₁ : V₁ ∈ 𝓤 β⟩
                ⟨K₂, V₂⟩ ⟨hK₂ : is_compact K₂, hV₂ : V₂ ∈ 𝓤 β⟩,
    refine ⟨⟨K₁ ∪ K₂, V₁ ∩ V₂⟩, ⟨hK₁.union hK₂, filter.inter_mem hV₁ hV₂⟩, _⟩,
    simp only [le_eq_subset, prod.forall, mem_inter_eq, mem_union_eq, set_of_subset_set_of,
      ge_iff_le, order.preimage],
    exact ⟨λ f g h x hx, (h x (or.inl hx)).1, λ f g h x hx, (h x (or.inr hx)).2⟩, },
end

lemma uniform_gen_subset (X : set C(α, β)) :
  uniform_gen K V f ⊆ X ↔ ∀ (g₁ g₂ : C(α, β)), (∀ x, x ∈ K → (g₁ x, g₂ x) ∈ V) → g₁ = f → g₂ ∈ X :=
begin
  refine ⟨_, λ hX g hg, hX f g hg rfl⟩,
  rintros hX g₁ g₂ hg₁ rfl,
  exact hX hg₁,
end

instance : uniform_space C(α, β) :=
{ uniformity := compact_convergence_uniformity,
  refl :=
    begin
      simp only [compact_convergence_uniformity, and_imp, filter.le_principal_iff, prod.forall,
        filter.mem_principal, mem_set_of_eq, le_infi_iff, id_rel_subset],
      intros K V hK hV f x hx,
      exact refl_mem_uniformity hV,
    end,
  symm :=
    begin
      simp only [compact_convergence_uniformity, and_imp, prod.forall, mem_set_of_eq, prod.fst_swap,
        filter.tendsto_principal, prod.snd_swap, filter.tendsto_infi],
      intros K V hK hV,
      obtain ⟨V', hV', hsymm, hsub⟩ := symm_of_uniformity hV,
      let U := { fg : C(α, β) × C(α, β) | ∀ (x : α), x ∈ K → (fg.1 x, fg.2 x) ∈ V' },
      apply @filter.eventually_of_mem _ _ _ U _ (λ fg hfg x hx, hsub (hsymm _ _ (hfg x hx))),
      change U ∈ compact_convergence_uniformity,
      rw mem_compact_convergence_uniformity,
      refine ⟨K, V', hK, hV', _⟩,
      simp only [prod.forall, imp_self, set_of_subset_set_of, forall_2_true_iff],
    end,
  comp :=
    begin
      intros X hX,
      obtain ⟨K, V, hK, hV, hX⟩ := (mem_compact_convergence_uniformity _).mp hX,
      obtain ⟨V', hV', hcomp⟩ := comp_mem_uniformity_sets hV,
      let h : set (C(α, β) × C(α, β)) → set (C(α, β) × C(α, β)) := λ s, s ○ s,
      suffices : h {fg : C(α, β) × C(α, β) | ∀ x, x ∈ K → (fg.1 x, fg.2 x) ∈ V'} ∈
                 compact_convergence_uniformity.lift' h,
      { change X ∈ compact_convergence_uniformity.lift' h,
        apply filter.mem_of_superset this,
        simp only [h],
        rintros ⟨f, g⟩ hfg,
        apply hX,
        intros x hx,
        apply hcomp,
        rw mem_comp_rel at hfg ⊢,
        obtain ⟨z, hz₁, hz₂⟩ := hfg,
        exact ⟨z x, hz₁ x hx, hz₂ x hx⟩, },
      apply filter.mem_lift',
      rw mem_compact_convergence_uniformity,
      exact ⟨K, V', hK, hV', subset.refl _⟩,
    end,
  is_open_uniformity :=
    begin
      simp only [← compact_open_eq_uniform],
      intros X,
      refine forall_congr (λ f, forall_congr (λ hf, _)),
      rw [mem_compact_convergence_filter, mem_compact_convergence_uniformity],
      refine exists_congr (λ K, exists_congr (λ V, _)),
      refine exists_congr (λ hK, exists_congr (λ hV, _)),
      simp only [prod.forall, set_of_subset_set_of, uniform_gen_subset],
    end }
