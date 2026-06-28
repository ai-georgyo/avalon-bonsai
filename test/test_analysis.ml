open! Core
open Avalon_core

let lines l = String.concat ~sep:"\n" l

(* A clean good win where evil was never placed on a mission. Locks in the badge engine:
   the exact set here matches what the live e2e game produced (Lockdown / Clean sweep /
   "I trust you guys"), plus the deductions that follow from the fixture's roles. *)
let%test_unit "badges for a clean good win" =
  let t = Analysis.create Fixtures.good_win ~role_map:Fixtures.role_map in
  let actual = lines (List.map (Analysis.get_badges t) ~f:(fun (b : Analysis.badge) -> sprintf "- %s: %s" b.title b.body)) in
  [%test_result: string]
    actual
    ~expect:
      (lines
         [ "- Lockdown: No evil players went on any missions"
         ; "- Clean sweep: Good team dominated the game"
         ; "- I trust you guys: CARL proposed a team that did not include themselves"
         ; "- What a trusting bunch: First mission got approved within 1 try"
         ; "- Put me in, coach!: DAVE did not go on a single mission"
         ; "- Cover blown: Morgana approved a team with Merlin"
         ; "- Yes-man: ALICE approved every single proposal"
         ; "- Ghost: DAVE was evil but never went on a single mission"
         ])
;;
