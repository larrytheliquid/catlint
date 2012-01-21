open import FRP.JS.Behaviour
open import FRP.JS.DOM
open import FRP.JS.RSet

module Catlint where

main : ∀ {w} → ⟦ Beh (DOM w) ⟧
main = text [ "residence_is_a_house" ]
