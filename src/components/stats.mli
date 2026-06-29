open! Core
open Bonsai_web
open Avalon_core
open Types

(** Win/loss statistics table. *)
val stats_display : stats option -> stats option -> Vdom.Node.t
