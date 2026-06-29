open! Core
open Bonsai_web

(** In-game participants panel (live player list + Players/Roles tab toggle). [selected] and
    [set_selected] are the shared team-selection state owned by {!Game_board}. *)
val game_participants
  :  selected:string list Bonsai.t
  -> set_selected:(string list -> unit Effect.t) Bonsai.t
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t
