open import FRP.JS.Nat
open import FRP.JS.String hiding (_++_; length)
open import FRP.JS.List hiding (_++_; [_]; map)
open import FRP.JS.Behaviour
open import FRP.JS.DOM hiding ([])
open import FRP.JS.RSet

module Catlint where

record Morphism : Set where
  constructor morphism
  field
    name   : String
    source : String
    target : String

morphisms : ⟦ Beh ⟨ List Morphism ⟩ ⟧
morphisms = [ xs ] where
  xs =
    morphism "business_is_a_house"  "business"  "house" ∷
    morphism "residence_is_a_house" "residence" "house" ∷ []

span : ∀ {w} value class → ⟦ Beh (DOM w) ⟧
span value class =
  element "span" content where
  content = attr "class" [ class ] ++ text [ value ]

morphismsCount$ : ∀ {w} → ⟦ Beh ⟨ List Morphism ⟩ ⇒ Beh (DOM w) ⟧
morphismsCount$ xs = element "div" content where
  showLength = λ xs → show (length xs)
  content = text (map showLength xs)

morphism$ : ∀ {w} name source target → ⟦ Beh (DOM w) ⟧
morphism$ name source target =
  element "div" content where
  content = attr "class" [ "equation" ] ++
    span name "morphism btn span2 primary" ++
    span " : " "equation-text" ++
    span source "btn span2 info" ++
    span " → " "equation-text" ++
    span target "btn span2 info"

morphisms$ : ∀ {w} → ⟦ Beh (DOM w) ⟧
morphisms$ =
  morphismsCount$ morphisms ++
  morphism$ "business_is_a_house" "business" "house" ++
  morphism$ "residence_is_a_house" "residence" "house"

main : ∀ {w} → ⟦ Beh (DOM w) ⟧
main = morphisms$

