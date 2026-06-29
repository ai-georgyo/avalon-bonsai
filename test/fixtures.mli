open! Core
open Avalon_core
open Types

(** Hand-built game_data fixtures for the pure-logic tests. *)

val role_map : role String.Map.t
val players : string list
val role_names : string list
val roles_assignment : role_assignment list

(* proposal / mission builders *)
val approved : string -> string list -> proposal
val pending : string -> proposal
val rejected : string -> string list -> proposal
val all_true : string list -> bool String.Map.t
val success : size:int -> team:string list -> proposer:string -> mission
val pending_mission : size:int -> mission

(* completed / in-progress games *)
val good_win : game_data
val evil_win : game_data
val psychic_tie : game_data
val mid_game : game_data
