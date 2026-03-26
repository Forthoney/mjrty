import Init.Data.Iterators.Lemmas.Consumers.Loop

variable {α} [DecidableEq α]

def mjrtyStep (state : α × Nat) (x : α) :=
  match state with
  | (_, 0) => (x, 1)
  | (candidate, n + 1) =>
    if x = candidate then
      (candidate, n + 2)
    else
      (candidate, n)

namespace List

def IsMajority (xs : List α) (x : α) : Prop :=
  xs.count x > xs.length / 2

def HasMajority (xs : List α) : Prop :=
  ∃ x, IsMajority xs x

def mjrty [Inhabited α] (xs : List α) : α :=
  xs.foldl mjrtyStep (default, 0) |>.1

theorem mjrty_invariant (xs : List α) (M candidate : α) (n : Nat)
  (h : 2 * xs.count M + (if candidate = M then n else 0) > xs.length + (if candidate ≠ M then n else 0)) :
  (xs.foldl mjrtyStep (candidate, n)).1 = M := by
  induction xs generalizing candidate n with
  | nil =>
    by_cases hcand : candidate = M
    · exact hcand
    · simp [hcand] at h
  | cons x xs ih =>
    cases n with
    | zero =>
      simp only [List.foldl, mjrtyStep]
      apply ih
      grind
    | succ n' =>
      by_cases hx : x = candidate
      <;> by_cases hcand : candidate = M
      <;> simp [List.foldl, mjrtyStep, hx, hcand] at h ⊢
      <;> grind

theorem mjrty_find_majority_if_exists [Inhabited α] :
  ∀ xs : List α, xs.HasMajority → xs.IsMajority (mjrty xs) := by
  intro xs ⟨M, hM⟩
  unfold List.IsMajority
  have heq : mjrty xs = M := by
    unfold mjrty
    apply mjrty_invariant
    unfold List.IsMajority at hM
    by_cases h_def : (default : α) = M
    <;> simp [h_def]
    <;> omega
  rw [heq]
  exact hM

end List

namespace Std.Iter

def mjrty [Inhabited α] {σ : Type} [Std.Iterator σ Id α] [Std.IteratorLoop σ Id Id]
    (it : Std.Iter (α := σ) α) : α :=
  (it.fold mjrtyStep (default, 0)).1

theorem mjrtyIter_eq_mjrty [Inhabited α] {σ : Type}
    [Std.Iterator σ Id α] [Std.Iterators.Finite σ Id]
    [Std.IteratorLoop σ Id Id] [Std.LawfulIteratorLoop σ Id Id]
    (it : Std.Iter (α := σ) α) :
    mjrty it = it.toList.mjrty := by
  simp [mjrty, List.mjrty, Std.Iter.foldl_toList]

theorem mjrtyIter_find_majority_if_exists [Inhabited α] {σ : Type}
    [Std.Iterator σ Id α] [Std.Iterators.Finite σ Id]
    [Std.IteratorLoop σ Id Id] [Std.LawfulIteratorLoop σ Id Id]
    (it : Std.Iter (α := σ) α) :
    it.toList.HasMajority → it.toList.IsMajority (mjrty it) := by
  intro hmaj
  rw [mjrtyIter_eq_mjrty it]
  exact it.toList.mjrty_find_majority_if_exists hmaj

end Std.Iter
