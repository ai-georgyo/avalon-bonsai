open! Core

(** Port of the [Array.prototype.joinWithAnd] helper from the original client: [] -> "",
    [a] -> "a", [a;b] -> "a and b", [a;b;c] -> "a, b and c". *)
let join_with_and (items : string list) : string =
  match items with
  | [] -> ""
  | [ x ] -> x
  | _ ->
    let rev = List.rev items in
    let last = List.hd_exn rev in
    let init = List.rev (List.tl_exn rev) in
    String.concat ~sep:", " init ^ " and " ^ last
;;

(** lodash [difference]: elements of [a] not in [b], preserving order of [a]. *)
let difference (a : string list) (b : string list) : string list =
  let b_set = String.Set.of_list b in
  List.filter a ~f:(fun x -> not (Set.mem b_set x))
;;
