open import FRP.JS.Behaviour
open import FRP.JS.DOM
open import FRP.JS.RSet

module Catlint where

span : ∀ {w} value class → ⟦ Beh (DOM w) ⟧
span value class =
  element "span" content where
  content = attr "class" [ class ] ++ text [ value ]

morphism : ∀ {w} name source target → ⟦ Beh (DOM w) ⟧
morphism name source target =
  element "div" content where
  content = attr "class" [ "equation" ] ++
    span name "morphism btn span2 primary" ++
    span " : " "equation-text" ++
    span source "btn span2 info" ++
    span " → " "equation-text" ++
    span target "btn span2 info"

morphisms : ∀ {w} → ⟦ Beh (DOM w) ⟧
morphisms =
  morphism "business_is_a_house" "business" "house" ++
  morphism "residence_is_a_house" "residence" "house"

main : ∀ {w} → ⟦ Beh (DOM w) ⟧
main = morphisms

