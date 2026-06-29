open! Core
open Bonsai_web

(** Full-screen event dialogs (game-started, mission result, end-game summary). *)
val modals : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
