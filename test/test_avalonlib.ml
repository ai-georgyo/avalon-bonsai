open! Core
open Avalon_core

let lines l = String.concat ~sep:"\n" l

let%test_unit "evil count by game size" =
  let actual =
    lines
      (List.map [ 3; 4; 5; 6; 7; 8; 9; 10; 11 ] ~f:(fun n ->
         sprintf "%2d -> %s" n (Option.value_map (Avalonlib.get_num_evil_for_game_size n) ~default:"none" ~f:Int.to_string)))
  in
  [%test_result: string]
    actual
    ~expect:(lines [ " 3 -> none"; " 4 -> none"; " 5 -> 2"; " 6 -> 2"; " 7 -> 3"; " 8 -> 3"; " 9 -> 3"; "10 -> 4"; "11 -> none" ])
;;

let%test_unit "role catalog invariants" =
  let actual =
    lines
      [ sprintf "roles=%d selectable=%d map=%d" (List.length Avalonlib.roles) (List.length Avalonlib.selectable_roles) (Map.length Avalonlib.role_map)
      ; sprintf "index: MERLIN=%d ASSASSIN=%d UNKNOWN=%d" (Avalonlib.role_index "MERLIN") (Avalonlib.role_index "ASSASSIN") (Avalonlib.role_index "NOPE")
      ]
  in
  [%test_result: string] actual ~expect:(lines [ "roles=8 selectable=6 map=8"; "index: MERLIN=0 ASSASSIN=7 UNKNOWN=-1" ])
;;

let%test_unit "only evil roles carry an assassination priority" =
  let actual =
    lines
      (List.map Avalonlib.roles ~f:(fun r ->
         sprintf "%-15s %-5s prio=%s" r.name (Types.team_to_string r.team) (Option.value_map r.assassination_priority ~default:"-" ~f:Int.to_string)))
  in
  [%test_result: string]
    actual
    ~expect:
      (lines
         [ "MERLIN          good  prio=-"
         ; "PERCIVAL        good  prio=-"
         ; "LOYAL FOLLOWER  good  prio=-"
         ; "MORGANA         evil  prio=2"
         ; "MORDRED         evil  prio=3"
         ; "OBERON          evil  prio=1"
         ; "EVIL MINION     evil  prio=4"
         ; "ASSASSIN        evil  prio=10"
         ])
;;
