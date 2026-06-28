open! Core

(** REST client (port of client/src/avalon-api-rest.ts). Each call POSTs JSON to
    /api/<endpoint> with a fresh Firebase ID token. [on_ok] receives the parsed JSON
    response; [on_err] receives an error message. *)

val login : ?on_ok:(Ffi.any -> unit) -> ?on_err:(string -> unit) -> string option -> unit
val join_lobby : on_ok:(Ffi.any -> unit) -> on_err:(string -> unit) -> name:string -> lobby:string -> unit
val create_lobby : on_ok:(Ffi.any -> unit) -> on_err:(string -> unit) -> name:string -> unit
val leave_lobby : ?on_ok:(Ffi.any -> unit) -> ?on_err:(string -> unit) -> lobby:string -> unit -> unit
val kick_player : ?on_ok:(Ffi.any -> unit) -> ?on_err:(string -> unit) -> lobby:string -> name:string -> unit -> unit
val cancel_game : ?on_ok:(Ffi.any -> unit) -> ?on_err:(string -> unit) -> lobby:string -> name:string -> unit -> unit

val vote_team
  :  ?on_ok:(Ffi.any -> unit)
  -> ?on_err:(string -> unit)
  -> lobby:string
  -> name:string
  -> mission:int
  -> proposal:int
  -> vote:bool
  -> unit
  -> unit

val start_game
  :  ?on_ok:(Ffi.any -> unit)
  -> ?on_err:(string -> unit)
  -> lobby:string
  -> player_list:string list
  -> roles:string list
  -> in_game_log:bool
  -> unit
  -> unit

val propose_team
  :  ?on_ok:(Ffi.any -> unit)
  -> ?on_err:(string -> unit)
  -> lobby:string
  -> name:string
  -> mission:int
  -> proposal:int
  -> team:string list
  -> unit
  -> unit

val do_mission
  :  ?on_ok:(Ffi.any -> unit)
  -> ?on_err:(string -> unit)
  -> lobby:string
  -> name:string
  -> mission:int
  -> proposal:int
  -> vote:bool
  -> unit
  -> unit

val assassinate
  :  ?on_ok:(Ffi.any -> unit)
  -> ?on_err:(string -> unit)
  -> lobby:string
  -> name:string
  -> target:string
  -> unit
  -> unit
