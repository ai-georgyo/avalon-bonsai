open! Core
open Types

(** Port of common/avalonlib.ts: the canonical role list and team sizing. *)

let roles : role list =
  [ { name = "MERLIN"
    ; team = Good
    ; sees = [ "MORGANA"; "OBERON"; "ASSASSIN"; "EVIL MINION" ]
    ; description =
        "Merlin sees all evil people (except for Mordred), but can also be assassinated."
    ; selectable = true
    ; filler = false
    ; default_selected = true
    ; assassination_priority = None
    }
  ; { name = "PERCIVAL"
    ; team = Good
    ; sees = [ "MERLIN"; "MORGANA" ]
    ; description =
        "Percival can see Merlin and Morgana but does not know which one is which."
    ; selectable = true
    ; filler = false
    ; default_selected = true
    ; assassination_priority = None
    }
  ; { name = "LOYAL FOLLOWER"
    ; team = Good
    ; sees = []
    ; description = "Loyal Follower is a genuinely good person."
    ; selectable = false
    ; filler = true
    ; default_selected = false
    ; assassination_priority = None
    }
  ; { name = "MORGANA"
    ; team = Evil
    ; sees = [ "MORDRED"; "ASSASSIN"; "EVIL MINION" ]
    ; description =
        "Morgana appears indistinguishable from Merlin to Percival. She sees other evil \
         people (except Oberon)"
    ; selectable = true
    ; filler = false
    ; default_selected = true
    ; assassination_priority = Some 2
    }
  ; { name = "MORDRED"
    ; team = Evil
    ; sees = [ "MORGANA"; "ASSASSIN"; "EVIL MINION" ]
    ; description =
        "Mordred is invisible to Merlin. Mordred can see other evil people (except \
         Oberon)"
    ; selectable = true
    ; filler = false
    ; default_selected = false
    ; assassination_priority = Some 3
    }
  ; { name = "OBERON"
    ; team = Evil
    ; sees = []
    ; description =
        "Oberon does not see anyone on his team and his teammates do not see him."
    ; selectable = true
    ; filler = false
    ; default_selected = false
    ; assassination_priority = Some 1
    }
  ; { name = "EVIL MINION"
    ; team = Evil
    ; sees = [ "MORGANA"; "MORDRED"; "ASSASSIN"; "EVIL MINION" ]
    ; description =
        "Evil Minion is pretty evil. He can see other evil people (except Oberon)"
    ; selectable = false
    ; filler = true
    ; default_selected = false
    ; assassination_priority = Some 4
    }
  ; { name = "ASSASSIN"
    ; team = Evil
    ; sees = [ "MORGANA"; "MORDRED"; "EVIL MINION" ]
    ; description =
        "The same as Evil Minion, but guaranteed to be the Assassin. They can see other \
         evil people (except Oberon)"
    ; selectable = true
    ; filler = false
    ; default_selected = false
    ; assassination_priority = Some 10
    }
  ]
;;

let role_map : role String.Map.t =
  String.Map.of_alist_exn (List.map roles ~f:(fun r -> r.name, r))
;;

let selectable_roles : role list = List.filter roles ~f:(fun r -> r.selectable)

(** Index of a role name in the canonical [roles] order (for stable sorting). *)
let role_index (name : string) : int =
  match List.findi roles ~f:(fun _ r -> String.equal r.name name) with
  | Some (i, _) -> i
  | None -> -1
;;

let get_num_evil_for_game_size (num_players : int) : int option =
  match num_players with
  | 5 -> Some 2
  | 6 -> Some 2
  | 7 -> Some 3
  | 8 -> Some 3
  | 9 -> Some 3
  | 10 -> Some 4
  | _ -> None
;;
