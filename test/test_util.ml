open! Core
open Avalon_core

let lines l = String.concat ~sep:"\n" l

let%test_unit "join_with_and covers 0..4 elements" =
  let j = Util.join_with_and in
  [%test_result: string]
    (lines
       [ j []; j [ "A" ]; j [ "A"; "B" ]; j [ "A"; "B"; "C" ]; j [ "A"; "B"; "C"; "D" ] ])
    ~expect:(lines [ ""; "A"; "A and B"; "A, B and C"; "A, B, C and D" ])
;;

let%test_unit "difference keeps order and drops present elements" =
  [%test_result: string list]
    (Util.difference [ "A"; "B"; "C"; "D" ] [ "B"; "D" ])
    ~expect:[ "A"; "C" ];
  [%test_result: string list] (Util.difference [ "A"; "B" ] []) ~expect:[ "A"; "B" ];
  [%test_result: string list] (Util.difference [] [ "A" ]) ~expect:[]
;;

(* The Firestore-string -> variant boundary: known tokens map through, everything else
   falls to the permissive default (Pending / M_pending / Canceled / Init). *)
let%test_unit "string parsers map known and unknown tokens" =
  let show f tokens conv = List.map tokens ~f:(fun s -> Sexp.to_string (conv (f s))) in
  let actual =
    lines
      (List.concat
         [ show Types.proposal_state_of_string [ "APPROVED"; "REJECTED"; "???" ] (fun v ->
             [%sexp (v : Types.proposal_state)])
         ; show Types.mission_state_of_string [ "SUCCESS"; "FAIL"; "???" ] (fun v ->
             [%sexp (v : Types.mission_state)])
         ; show Types.outcome_state_of_string [ "GOOD_WIN"; "EVIL_WIN"; "???" ] (fun v ->
             [%sexp (v : Types.outcome_state)])
         ; show Types.game_state_of_string [ "ACTIVE"; "ENDED"; "???" ] (fun v ->
             [%sexp (v : Types.game_state)])
         ])
  in
  [%test_result: string]
    actual
    ~expect:
      (lines
         [ "Approved"
         ; "Rejected"
         ; "Pending"
         ; "Success"
         ; "Fail"
         ; "M_pending"
         ; "Good_win"
         ; "Evil_win"
         ; "Canceled"
         ; "Active"
         ; "Game_ended"
         ; "Init"
         ])
;;
