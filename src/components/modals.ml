open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Avalon_core
open Types
open Ui
module M = State.Model
module D = State.Derived
module N = Vdom.Node

(** Full-screen event dialogs driven by the model's [modal] field: game-started, a
    mission result, and the end-game summary (with the mission grid and achievements). *)

module Style =
  [%css
  stylesheet
    {|
  .endgame_title { background: #80deea; text-align: center; justify-content: center; }
  .endgame_message { font-size: 1.25rem; text-align: center; }
  .endgame_table_wrap { overflow-x: auto; width: 100%; }
|}]

let modals (local_ graph) =
  let%arr m = State.value () in
  let close = eff (fun () -> State.set_modal No_modal) in
  match m.modal, D.game m with
  | M.Start_game, _ ->
    overlay ~on_close:Effect.(return ())
      [ card_title ~attrs:[ Ui.title_bar ] [ N.h3 [ N.text "Game Started" ] ]
      ; card_text [ N.p [ N.text "A new game has started. When you are ready, view your secret role." ]; N.p [ N.text "You may also view your role anytime by clicking on your name in the toolbar." ] ]
      ; div ~attrs:[ Ui.row; Ui.actions ] [ btn ~on_click:(eff (fun () -> State.set_modal No_modal; State.set_show_role_sheet true)) [ N.text "View Role" ] ]
      ]
  | M.Mission_result, Some g ->
    let idx = if g.current_mission_idx < 0 then List.length (Game.missions g) else g.current_mission_idx in
    (match List.nth (Game.missions g) (idx - 1) with
     | None -> N.none
     | Some mission ->
       let title =
         match mission.state with
         | Success -> N.div [ fa ~color:"green" "fas" "fa-check-circle"; N.text " Mission Succeeded!" ]
         | _ -> N.div [ fa ~color:"red" "fas" "fa-times-circle"; N.text " Mission Failed!" ]
       in
       overlay ~on_close:close
         [ card_title ~attrs:[ Ui.title_bar ] [ title ]
         ; card_text [ textf "%s had %s failure %s" (Util.join_with_and mission.team) (if mission.num_fails > 0 then Int.to_string mission.num_fails else "no") (if mission.num_fails = 1 then "vote." else "votes.") ]
         ; div ~attrs:[ Ui.row; Ui.actions ] [ btn ~on_click:close [ N.text "Close" ] ]
         ])
  | M.End_game, Some g ->
    (match Game.outcome g with
     | None -> N.none
     | Some o ->
       let title = match o.state with Good_win -> "Good wins!" | Evil_win -> "Evil wins!" | Canceled -> "Game Canceled" in
       let role_assignments = List.sort o.roles ~compare:(fun a b -> Int.compare (Avalonlib.role_index a.role) (Avalonlib.role_index b.role)) in
       let missions = List.filter (Game.missions g) ~f:(fun mi -> List.exists mi.proposals ~f:(fun p -> not (equal_proposal_state p.state Pending))) in
       let assassinated =
         match o.assassinated with
         | Some a -> N.p [ textf "%s was assassinated by %s" a (Option.value_map (List.find o.roles ~f:(fun r -> r.assassin)) ~default:"" ~f:(fun r -> r.name)) ]
         | None -> N.none
       in
       let body =
         div ~attrs:[ Ui.col; Ui.center ]
           [ {%html.jsx|<div *{[ Style.endgame_message; Ui.fw ]}>#{o.message}</div>|}
           ; assassinated
           ; div ~attrs:[ Style.endgame_table_wrap ] [ Summary_table.mission_summary_table ~players:(Game.players g) ~missions ~roles:(Some role_assignments) ~mission_votes:(Some o.votes) ]
           ; Achievements.achievements g
           ; btn ~attrs:[ Ui.mt_6; Ui.primary ] ~on_click:close [ N.text "Close" ]
           ]
       in
       overlay ~fullscreen:true ~on_close:close
         [ card_title ~attrs:[ Style.endgame_title ] [ spanc ~attrs:[ Ui.text_h4; Ui.fw ] [ N.text title ] ]; card_text [ body ] ])
  | _ -> N.none
;;
