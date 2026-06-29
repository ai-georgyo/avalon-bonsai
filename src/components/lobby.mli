open! Core
open Bonsai_web

(** Choose/create a lobby (with the user's stats below). *)
val lobby_select : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t

(** Pre-game lobby: player list, selectable roles, and start controls. *)
val game_lobby : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
