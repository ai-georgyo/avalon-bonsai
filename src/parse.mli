open! Core
open Avalon_core
open Types

(** Firestore JS objects -> typed records. Only the entry points used by {!State} are
    exposed; the per-field parsers are private. *)

val lobby_data : Ffi.any -> lobby_data
val role_doc : Ffi.any -> role_doc option
val stats : Ffi.any -> stats
val user_data : Ffi.any -> user_data
