open! Core
open Avalon_core

let lines l = String.concat ~sep:"\n" l

let%test_unit "init game derives no current mission" =
  let g = Game.create { Fixtures.good_win with state = Init; outcome = None } ~role_map:Fixtures.role_map in
  let actual =
    sprintf "num_players=%d mission_idx=%d proposal_idx=%d proposer=%s"
      g.num_players g.current_mission_idx g.current_proposal_idx (Option.value g.current_proposer ~default:"-")
  in
  [%test_result: string] actual ~expect:"num_players=0 mission_idx=-1 proposal_idx=-1 proposer=-"
;;

let%test_unit "mid game derives current proposer, hammer, and team balance" =
  let g = Game.create Fixtures.mid_game ~role_map:Fixtures.role_map in
  let actual =
    lines
      [ sprintf "num_players=%d mission_idx=%d proposal_idx=%d" g.num_players g.current_mission_idx g.current_proposal_idx
      ; sprintf "proposer=%s hammer=%s" (Option.value g.current_proposer ~default:"-") (Option.value g.hammer ~default:"-")
      ; sprintf "num_good=%d num_evil=%d" (Game.num_good g) (Game.num_evil g)
      ]
  in
  [%test_result: string]
    actual
    ~expect:(lines [ "num_players=5 mission_idx=0 proposal_idx=0"; "proposer=ALICE hammer=EVE"; "num_good=3 num_evil=2" ])
;;
