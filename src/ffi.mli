open! Core
open Js_of_ocaml

(** Low-level js_of_ocaml helpers for the compat Firebase SDK, [fetch], and reading
    fields out of plain JS objects. Only the helpers used by other modules are exposed. *)

(** An opaque JavaScript value. *)
type any = Js.Unsafe.any

val inject : 'a -> any
val is_nullish : any -> bool

(* readers *)
val get : any -> string -> any
val to_bool : any -> bool
val to_list : any -> any list
val keys : any -> string list
val field_string : ?default:string -> any -> string -> string
val field_string_opt : any -> string -> string option
val field_int : ?default:int -> any -> string -> int
val field_bool : ?default:bool -> any -> string -> bool
val field_str_list : any -> string -> string list

(* builders (OCaml -> JS) *)
val obj : (string * any) list -> any
val null_value : any
val of_string : string -> any
val of_bool : bool -> any
val of_int : int -> any
val of_str_list : string list -> any

(* promises *)
val promise_then : any -> on_ok:(any -> unit) -> on_err:(any -> unit) -> unit

(* Firebase (compat global) *)
val init_app : (string * any) list -> unit
val auth : unit -> any
val current_user : unit -> any
val doc : string list -> any
val on_snapshot : any -> on_next:(any -> unit) -> on_error:(any -> unit) -> unit -> unit
val get_doc : any -> on_ok:(any -> unit) -> on_err:(any -> unit) -> unit
val snapshot_exists : any -> bool
val snapshot_data : any -> any

(* window / location *)
val window_origin : unit -> string
val window_href : unit -> string
val set_document_title : string -> unit
val replace_state_to_pathname : unit -> unit
val alert : string -> unit
val url_has_param : string -> bool
val url_get_param : string -> string option
