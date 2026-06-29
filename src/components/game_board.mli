open! Core
open Bonsai_web

(** The in-game board (mission track + participants + action pane). *)
val game_board : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
