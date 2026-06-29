open! Core
open Bonsai_web

(** The mission track (tab strip + selected-mission detail panel). *)
val game_missions : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
