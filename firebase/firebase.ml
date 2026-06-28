open! Core
open Js_of_ocaml

(** Bindings to the Firebase v12 *modular* JS SDK.

    The project has no bundler, so the modular ESM entry points are imported in
    [web/index.html] and re-exported on the global [window.__fb]; these bindings call
    through that object with js_of_ocaml. Because the ESM import is asynchronous, callers
    must wrap Firebase setup in {!on_ready}, which fires once [window.__fb] is populated
    (the loader dispatches a [firebase-ready] event). *)

type any = Js.Unsafe.any
type auth = any
type firestore = any
type doc_ref = any
type snapshot = any
type user = any

let str = Js.string
let inject = Js.Unsafe.inject
let global = Js.Unsafe.global

let is_nullish (v : any) : bool =
  Js.to_bool (Js.Unsafe.fun_call (Js.Unsafe.js_expr "(function(x){return x===undefined||x===null;})") [| inject v |])
;;

(* The shim object installed by the ESM loader. *)
let api () : any = Js.Unsafe.get global (str "__fb")
let call (name : string) (args : any array) : any = Js.Unsafe.fun_call (Js.Unsafe.get (api ()) (str name)) args

let promise_then (p : any) ~(on_ok : any -> unit) ~(on_err : any -> unit) : unit =
  ignore (Js.Unsafe.meth_call p "then" [| inject (Js.wrap_callback on_ok); inject (Js.wrap_callback on_err) |] : any)
;;

let app_ref : any option ref = ref None
let app () : any = match !app_ref with Some a -> a | None -> failwith "Firebase.init has not been called"

let init (config : (string * any) list) : unit =
  let cfg = Js.Unsafe.obj (Array.of_list config) in
  app_ref := Some (call "initializeApp" [| inject cfg |])
;;

let auth () : auth = call "getAuth" [| inject (app ()) |]
let firestore () : firestore = call "getFirestore" [| inject (app ()) |]
let current_user () : user = Js.Unsafe.get (auth ()) (str "currentUser")

let on_auth_state_changed (cb : user -> unit) : unit =
  ignore (call "onAuthStateChanged" [| inject (auth ()); inject (Js.wrap_callback cb) |] : any)
;;

let sign_in_anonymously ~(on_err : any -> unit) : unit =
  promise_then (call "signInAnonymously" [| inject (auth ()) |]) ~on_ok:(fun _ -> ()) ~on_err
;;

let sign_in_with_email_link ~(email : string) ~(href : string) ~(on_ok : any -> unit) ~(on_err : any -> unit) : unit =
  promise_then (call "signInWithEmailLink" [| inject (auth ()); inject (str email); inject (str href) |]) ~on_ok ~on_err
;;

let send_sign_in_link_to_email ~(email : string) ~(settings : any) ~(on_ok : any -> unit) ~(on_err : any -> unit) : unit =
  promise_then (call "sendSignInLinkToEmail" [| inject (auth ()); inject (str email); inject settings |]) ~on_ok ~on_err
;;

let sign_out () : unit = ignore (call "signOut" [| inject (auth ()) |] : any)

(* Modular [doc(db, ...pathSegments)] replaces compat's collection/doc chaining. *)
let doc (path : string list) : doc_ref =
  call "doc" (Array.of_list (inject (firestore ()) :: List.map path ~f:(fun s -> inject (str s))))
;;

let on_snapshot (ref : doc_ref) ~(on_next : snapshot -> unit) ~(on_error : any -> unit) : unit -> unit =
  let unsub = call "onSnapshot" [| inject ref; inject (Js.wrap_callback on_next); inject (Js.wrap_callback on_error) |] in
  fun () -> ignore (Js.Unsafe.fun_call unsub [||] : any)
;;

let get_doc (ref : doc_ref) ~(on_ok : any -> unit) ~(on_err : any -> unit) : unit =
  promise_then (call "getDoc" [| inject ref |]) ~on_ok ~on_err
;;

(* Modular SDK: [exists()] is a METHOD on the snapshot (the compat SDK exposed [exists] as a
   boolean property); [data()] is a method in both. *)
let snapshot_exists (snap : snapshot) : bool = Js.to_bool (Js.Unsafe.coerce (Js.Unsafe.meth_call snap "exists" [||]))
let snapshot_data (snap : snapshot) : any = Js.Unsafe.meth_call snap "data" [||]

let on_ready (f : unit -> unit) : unit =
  if not (is_nullish (api ()))
  then f ()
  else (
    let handler = Js.wrap_callback (fun (_ : any) -> f ()) in
    ignore
      (Js.Unsafe.fun_call
         (Js.Unsafe.js_expr "(function(h){window.addEventListener('firebase-ready',h,{once:true});})")
         [| inject handler |]
        : any))
;;
