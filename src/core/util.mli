(** Small string-list helpers ported from the original client. *)

(** [[] -> ""], [[a] -> "a"], [[a;b] -> "a and b"], [[a;b;c] -> "a, b and c"]. *)
val join_with_and : string list -> string

(** Elements of the first list not present in the second, preserving order. *)
val difference : string list -> string list -> string list
