open! Core
open Avalon_core
open Types

(** Hand-built game_data fixtures for the pure-logic tests. The 5-player layout mirrors
    the e2e games: ALICE=MERLIN, BOB=PERCIVAL, CARL=LOYAL FOLLOWER (good); DAVE=MORGANA,
    EVE=ASSASSIN (evil). *)

let role_map = Avalonlib.role_map
let players = [ "ALICE"; "BOB"; "CARL"; "DAVE"; "EVE" ]

let roles_assignment : role_assignment list =
  [ { name = "ALICE"; role = "MERLIN"; assassin = false }
  ; { name = "BOB"; role = "PERCIVAL"; assassin = false }
  ; { name = "CARL"; role = "LOYAL FOLLOWER"; assassin = false }
  ; { name = "DAVE"; role = "MORGANA"; assassin = false }
  ; { name = "EVE"; role = "ASSASSIN"; assassin = true }
  ]

let role_names = [ "MERLIN"; "PERCIVAL"; "LOYAL FOLLOWER"; "MORGANA"; "ASSASSIN" ]
let approved (proposer : string) (team : string list) : proposal = { proposer; team; votes = players; state = Approved }
let pending (proposer : string) : proposal = { proposer; team = []; votes = []; state = Pending }

let success ~size ~team ~proposer : mission =
  { state = Success; team; team_size = size; fails_required = 1; num_fails = 0; proposals = [ approved proposer team ] }

let pending_mission ~size : mission =
  { state = M_pending; team = []; team_size = size; fails_required = 1; num_fails = 0; proposals = [] }

(* A completed good win in which evil was never sent on a mission (good teams only). *)
let good_win : game_data =
  let mission_votes =
    let all_true team = String.Map.of_alist_exn (List.map team ~f:(fun n -> n, true)) in
    [ all_true [ "ALICE"; "BOB" ]; all_true [ "ALICE"; "BOB"; "CARL" ]; all_true [ "ALICE"; "BOB" ] ]
  in
  { state = Game_ended
  ; phase = "GOOD_WIN"
  ; players
  ; roles = role_names
  ; missions =
      [ success ~size:2 ~team:[ "ALICE"; "BOB" ] ~proposer:"ALICE"
      ; success ~size:3 ~team:[ "ALICE"; "BOB"; "CARL" ] ~proposer:"BOB"
      ; success ~size:2 ~team:[ "ALICE"; "BOB" ] ~proposer:"CARL"
      ; pending_mission ~size:3
      ; pending_mission ~size:3
      ]
  ; outcome = Some { state = Good_win; message = "Good wins!"; assassinated = None; roles = roles_assignment; votes = mission_votes }
  ; in_game_log = false
  }

(* An in-progress game: mission 1, first proposal pending, proposed by ALICE. *)
let mid_game : game_data =
  { state = Active
  ; phase = "TEAM_SELECTION"
  ; players
  ; roles = role_names
  ; missions =
      ({ state = M_pending; team = []; team_size = 2; fails_required = 1; num_fails = 0; proposals = [ pending "ALICE" ] } : mission)
      :: List.map [ 3; 2; 3; 3 ] ~f:(fun size -> pending_mission ~size)
  ; outcome = None
  ; in_game_log = false
  }
