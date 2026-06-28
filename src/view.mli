open! Core

(** The view layer. Every component is private; the application is started through the
    single entry point below (called from [bin/main.ml]). *)

(** Initialize {!State} and mount the Bonsai app on the [#app] element. *)
val run_app : unit -> unit
