open! Core
open Types

(** The canonical role catalog and team sizing (port of common/avalonlib.ts). *)

val roles : role list
val role_map : role String.Map.t
val selectable_roles : role list

(** Index of a role name in the canonical [roles] order, or [-1] if unknown. *)
val role_index : string -> int

(** Number of evil players for a given table size; [None] outside 5..10. *)
val get_num_evil_for_game_size : int -> int option
