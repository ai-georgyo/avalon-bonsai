open! Core
open Js_of_ocaml

(** Typed bindings to the Firebase v12 *modular* JS SDK.

    The handle types ({!user}, {!document_reference}, {!document_snapshot}, {!error}) are
    abstract and distinct, modeled on the [@firebase/auth] and [@firebase/firestore]
    TypeScript definitions, so the OCaml type system enforces that e.g. a snapshot can't be
    passed where a reference is expected, and JS objects are read only through the typed
    accessors below — never via raw [Js.Unsafe] in callers.

    The project has no bundler, so the modular ESM entry points are imported in
    [web/index.html] and re-exported on the global [window.__fb]; wrap setup in {!on_ready}
    so it runs only after that asynchronous import has populated the global. *)

type any = Js.Unsafe.any
type user = any
type document_reference = any
type document_snapshot = any
type error = any

type config =
  { api_key : string
  ; auth_domain : string
  ; database_url : string
  ; project_id : string
  ; storage_bucket : string
  ; messaging_sender_id : string
  ; app_id : string
  }

type action_code_settings =
  { url : string
  ; handle_code_in_app : bool
  }

let str = Js.string
let inject = Js.Unsafe.inject
let global = Js.Unsafe.global

let is_nullish (v : any) : bool =
  Js.to_bool (Js.Unsafe.fun_call (Js.Unsafe.js_expr "(function(x){return x===undefined||x===null;})") [| inject v |])
;;

let field_string_opt (o : any) (k : string) : string option =
  let v = Js.Unsafe.get o (str k) in
  if is_nullish v then None else Some (Js.to_string (Js.Unsafe.coerce v))
;;

let field_string ?(default = "") o k = Option.value (field_string_opt o k) ~default
let to_opt (v : any) : any option = if is_nullish v then None else Some v

(* The shim object installed by the ESM loader. *)
let api () : any = Js.Unsafe.get global (str "__fb")
let call (name : string) (args : any array) : any = Js.Unsafe.fun_call (Js.Unsafe.get (api ()) (str name)) args

let promise_then (p : any) ~(on_ok : any -> unit) ~(on_err : error -> unit) : unit =
  ignore (Js.Unsafe.meth_call p "then" [| inject (Js.wrap_callback on_ok); inject (Js.wrap_callback on_err) |] : any)
;;

(* ---- app (cached default app; auth/firestore handles derived lazily) ---- *)

let app_ref : any option ref = ref None
let app () : any = match !app_ref with Some a -> a | None -> failwith "Firebase.init has not been called"

let init (c : config) : unit =
  let cfg =
    Js.Unsafe.obj
      [| "apiKey", inject (str c.api_key)
       ; "authDomain", inject (str c.auth_domain)
       ; "databaseURL", inject (str c.database_url)
       ; "projectId", inject (str c.project_id)
       ; "storageBucket", inject (str c.storage_bucket)
       ; "messagingSenderId", inject (str c.messaging_sender_id)
       ; "appId", inject (str c.app_id)
      |]
  in
  app_ref := Some (call "initializeApp" [| inject cfg |])
;;

let auth () : any = call "getAuth" [| inject (app ()) |]
let firestore () : any = call "getFirestore" [| inject (app ()) |]

(* ---- auth ---- *)

let current_user () : user option = to_opt (Js.Unsafe.get (auth ()) (str "currentUser"))

let on_auth_state_changed (cb : user option -> unit) : unit =
  let wrapped = Js.wrap_callback (fun (u : any) -> cb (to_opt u)) in
  ignore (call "onAuthStateChanged" [| inject (auth ()); inject wrapped |] : any)
;;

let sign_in_anonymously ~(on_err : error -> unit) : unit =
  promise_then (call "signInAnonymously" [| inject (auth ()) |]) ~on_ok:(fun _ -> ()) ~on_err
;;

let sign_in_with_email_link ~(email : string) ~(link : string) ~(on_ok : unit -> unit) ~(on_err : error -> unit) : unit =
  promise_then
    (call "signInWithEmailLink" [| inject (auth ()); inject (str email); inject (str link) |])
    ~on_ok:(fun _ -> on_ok ())
    ~on_err
;;

let send_sign_in_link_to_email ~(email : string) ~(settings : action_code_settings) ~(on_ok : unit -> unit) ~(on_err : error -> unit) : unit =
  let s = Js.Unsafe.obj [| "url", inject (str settings.url); "handleCodeInApp", inject (Js.bool settings.handle_code_in_app) |] in
  promise_then
    (call "sendSignInLinkToEmail" [| inject (auth ()); inject (str email); inject s |])
    ~on_ok:(fun _ -> on_ok ())
    ~on_err
;;

let sign_out () : unit = ignore (call "signOut" [| inject (auth ()) |] : any)

(* ---- user accessors ---- *)

let uid (u : user) : string = field_string u "uid"
let email (u : user) : string option = field_string_opt u "email"
let display_name (u : user) : string option = field_string_opt u "displayName"

let get_id_token (u : user) ~(force_refresh : bool) ~(on_ok : string -> unit) ~(on_err : error -> unit) : unit =
  promise_then
    (Js.Unsafe.meth_call u "getIdToken" [| inject (Js.bool force_refresh) |])
    ~on_ok:(fun token -> on_ok (Js.to_string (Js.Unsafe.coerce token)))
    ~on_err
;;

(* ---- firestore ---- *)

(* Modular [doc(db, ...pathSegments)] replaces compat's collection/doc chaining. *)
let doc (path : string list) : document_reference =
  call "doc" (Array.of_list (inject (firestore ()) :: List.map path ~f:(fun s -> inject (str s))))
;;

let on_snapshot (ref : document_reference) ~(on_next : document_snapshot -> unit) ~(on_error : error -> unit) : unit -> unit =
  let unsub = call "onSnapshot" [| inject ref; inject (Js.wrap_callback on_next); inject (Js.wrap_callback on_error) |] in
  fun () -> ignore (Js.Unsafe.fun_call unsub [||] : any)
;;

let get_doc (ref : document_reference) ~(on_ok : document_snapshot -> unit) ~(on_err : error -> unit) : unit =
  promise_then (call "getDoc" [| inject ref |]) ~on_ok ~on_err
;;

(* ---- document snapshot ---- *)

(* Modular SDK: [exists()] is a METHOD (compat exposed [exists] as a property); [data()]
   returns DocumentData | undefined. *)
let exists (snap : document_snapshot) : bool = Js.to_bool (Js.Unsafe.coerce (Js.Unsafe.meth_call snap "exists" [||]))
let data (snap : document_snapshot) : any option = to_opt (Js.Unsafe.meth_call snap "data" [||])

(* ---- error ---- *)

let error_message (e : error) : string = field_string e "message"
let error_code (e : error) : string = field_string e "code"

(* ---- readiness ---- *)

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
