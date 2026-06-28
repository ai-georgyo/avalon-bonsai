open! Core
open Js_of_ocaml

(** Minimal imperative toast, replacing vue-toastification. Appends a message node to
    [#toast-container] (top-center) and removes it after a timeout. *)

let show (message : string) : unit =
  let doc = Js.Unsafe.js_expr "document" in
  let container =
    let c = Js.Unsafe.meth_call doc "getElementById" [| Ffi.of_string "toast-container" |] in
    if Ffi.is_nullish c
    then (
      let c = Js.Unsafe.meth_call doc "createElement" [| Ffi.of_string "div" |] in
      Js.Unsafe.set c (Js.string "id") (Js.string "toast-container");
      let body = Js.Unsafe.get doc "body" in
      let _ : Ffi.any = Js.Unsafe.meth_call body "appendChild" [| Ffi.inject c |] in
      c)
    else c
  in
  let node = Js.Unsafe.meth_call doc "createElement" [| Ffi.of_string "div" |] in
  Js.Unsafe.set node (Js.string "className") (Js.string "toast");
  Js.Unsafe.set node (Js.string "textContent") (Js.string message);
  let _ : Ffi.any = Js.Unsafe.meth_call container "appendChild" [| Ffi.inject node |] in
  let remove =
    Js.Unsafe.callback (fun () ->
      let _ : Ffi.any = Js.Unsafe.meth_call node "remove" [||] in
      ())
  in
  let _ : Ffi.any =
    Js.Unsafe.fun_call
      (Js.Unsafe.js_expr "window.setTimeout")
      [| Ffi.inject remove; Ffi.of_int 2500 |]
  in
  ()
;;
