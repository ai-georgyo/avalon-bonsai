open! Core
open Js_of_ocaml

(** Minimal imperative toast, replacing vue-toastification. Appends a message node to
    [#toast-container] (top-center) and removes it after a timeout. Uses the typed
    [Dom_html] API rather than raw [Js.Unsafe]. *)

let show (message : string) : unit =
  let doc = Dom_html.document in
  let container =
    Js.Opt.case
      (doc##getElementById (Js.string "toast-container"))
      (fun () ->
        let c = Dom_html.createDiv doc in
        c##.id := Js.string "toast-container";
        Dom.appendChild doc##.body c;
        (c :> Dom_html.element Js.t))
      (fun c -> c)
  in
  let node = Dom_html.createDiv doc in
  node##.className := Js.string "toast";
  node##.textContent := Js.some (Js.string message);
  Dom.appendChild container node;
  let remove () = Dom.removeChild container node in
  ignore (Dom_html.window##setTimeout (Js.wrap_callback remove) (Js.number_of_float 2500.))
;;
