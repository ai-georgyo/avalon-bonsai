open! Core
open Bonsai_web
open Avalon_core
open Types

(** Admin-selectable role list for the lobby (reads/writes the selected-roles set in {!State}). *)
val selectable_role_list : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t

(** Static read-only role list (in-game participants "Roles" tab). *)
val role_list_view : role list -> Vdom.Node.t
