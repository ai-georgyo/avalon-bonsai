open! Core
open Bonsai_web
open Avalon_core

(** End-game achievement badges ([N.none] when there are none or the game was canceled). *)
val achievements : Game.t -> Vdom.Node.t
