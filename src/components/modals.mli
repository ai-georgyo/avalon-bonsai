open! Core
open Bonsai_web

(** Registers the event dialogs (game-started, mission result, end-game summary), which
    are driven by the model's [modal] field and portaled into the top layer. Call for
    effect at graph level (it returns [unit] rather than a node to splice into the view). *)
val modals : local_ Bonsai.graph -> unit
