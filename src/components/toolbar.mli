open! Core
open Bonsai_web

(** The top app bar (lobby name, view-role bottom sheet, quit/logout). *)
val game_toolbar : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
