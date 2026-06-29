open! Core
open Bonsai_web

(** The login screen (email-link or anonymous sign-in). *)
val user_login : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
