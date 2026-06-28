open! Core
open Types

(** Post-game achievement ("badge") detection (port of client/src/avalon-analysis.ts).
    Construct with {!create} only for completed, non-canceled games; the ~40 individual
    detectors are private. *)

type t

type badge =
  { title : string
  ; body : string
  }

val create : game_data -> role_map:role String.Map.t -> t
val get_badges : t -> badge list
