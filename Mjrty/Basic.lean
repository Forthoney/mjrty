variable {α} [DecidableEq α]
namespace List

def IsMajority (xs : List α) (x : α) : Prop :=
  xs.count x > xs.length / 2

def HasMajority (xs : List α) : Prop :=
  ∃ x, IsMajority xs x

end List

def mjrty [Inhabited α] : List α → α :=
  go default 0
  where go (candidate : α) : Nat → List α → α
    | _, [] => candidate
    | 0, x :: xs => go x 1 xs
    | n + 1, x :: xs =>
      if x = candidate then
        go candidate (n + 2) xs
      else
        go candidate n xs

theorem mjrty_invariant (xs : List α) (M candidate : α) (n : Nat)
  (h : 2 * xs.count M + (if candidate = M then n else 0) > xs.length + (if candidate ≠ M then n else 0)) :
  mjrty.go candidate n xs = M := by
  induction xs generalizing candidate n with
  | nil =>
    by_cases hcand : candidate = M
    · exact hcand
    · simp [hcand] at h
  | cons x xs ih =>
    cases n with
    | zero =>
      apply ih
      grind
    | succ n' =>
      by_cases hx : x = candidate
      <;> by_cases hcand : candidate = M
      <;> simp [mjrty.go, hx, hcand] at h ⊢
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
