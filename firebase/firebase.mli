open Js_of_ocaml

(** Bindings to the Firebase v12 modular JS SDK, called through the [window.__fb] shim
    that [web/index.html] installs from the ESM build (no bundler). Wrap setup in
    {!on_ready} so it runs only after that asynchronous import has populated the global. *)

type any = Js.Unsafe.any

(** Run [f] once the modular SDK shim is available (immediately if already loaded). *)
val on_ready : (unit -> unit) -> unit

(** [initializeApp] the default app from a config object's fields. Must run before any
    other call below; do it inside {!on_ready}. *)
val init : (string * any) list -> unit

val auth : unit -> any
val firestore : unit -> any
val current_user : unit -> any
val on_auth_state_changed : (any -> unit) -> unit
val sign_in_anonymously : on_err:(any -> unit) -> unit
val sign_in_with_email_link : email:string -> href:string -> on_ok:(any -> unit) -> on_err:(any -> unit) -> unit
val send_sign_in_link_to_email : email:string -> settings:any -> on_ok:(any -> unit) -> on_err:(any -> unit) -> unit
val sign_out : unit -> unit

(** A document reference at the given path segments, e.g. [doc ["lobbies"; name]]. *)
val doc : string list -> any

(** Subscribe to realtime updates; returns the unsubscribe thunk. *)
val on_snapshot : any -> on_next:(any -> unit) -> on_error:(any -> unit) -> unit -> unit

val get_doc : any -> on_ok:(any -> unit) -> on_err:(any -> unit) -> unit
val snapshot_exists : any -> bool
val snapshot_data : any -> any
