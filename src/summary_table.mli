open! Core
open Bonsai_web
open Avalon_core
open Types

(** Per-player mission summary grid (in-game log + end-game dialog). *)
val mission_summary_table
  :  players:string list
  -> missions:mission list
  -> roles:role_assignment list option
  -> mission_votes:bool String.Map.t list option
  -> Vdom.Node.t
