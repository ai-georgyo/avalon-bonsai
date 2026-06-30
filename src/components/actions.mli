open! Core
open Bonsai_web

(** The phase-dependent action pane; [selected] is the shared team-selection state owned
    by {!Game_board}. Only the active phase's component is instantiated. *)
val action_pane
  :  selected:string list Bonsai.t
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t
