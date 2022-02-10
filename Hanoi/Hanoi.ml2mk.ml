(* Natural numbers in Peano encoding *)
type nat = O | S of nat

(* Names for pins *)
type pin = A | B | C

(*
Make these type definitions compile

type move = (pin, pin)
type set  = (nat list, nat list, nat list)
*)

(*
    Moves are represented as pars of pin names;
    the set is represented as triples of lists of
    natural numbers:


       =     |     |
      ===    |     |
     =====   |     |
   -------------------
      A      B     C   <- names for pins

    Representation: ([1, 2, 3], [], [])
 *)

(* nat -> nat -> bool

   Tests the ordering relation on natural numers:

   less x y = true <=> x < y
*)
let rec less x y =
  match y with
  | S y' -> match x with
           | O    -> true
           | S x' -> less x' y'

(* move -> pin

   Gets the name of the complementary pin for a given move
   (e.g. (A, B) -> C, etc.)
*)
let complement = function
| (A, B) -> C
| (B, A) -> C
| (A, C) -> B
| (C, A) -> B
| (B, C) -> A
| (C, B) -> A

(* set -> pin -> nat list

   Selects the contents of given pin by its name
 *)
let select (x, y, z) = function
| A -> x
| B -> y
| C -> z

(* move -> set -> set

   Makes a pseudo-set for given set and move:

   (from, to) -> set -> (set.from, set.to, set.complement)
*)
let selectMove ((x, y) as move) s =
  (select s x, select s y, select s (complement move))

(* set -> move -> set

   Permutes a pseudo set for a given move to get a "normal" set
 *)
let permutate ((x, y, z) as state) = function
| (A, B) -> state
| (B, A) -> (y, x, z)
| (A, C) -> (x, z, y)
| (C, A) -> (y, z, x)
| (B, C) -> (z, x, y)
| (C, B) -> (z, y, x)

(* move list -> set -> set

  Executes a given sequence of moves for given initial set and
  produces a final set (if possible)
*)
let[@tabled] rec eval p s =
  match p with
  | []         -> s
  | (x, y) as move :: p' ->
     eval p'
       (if x = y
         then s
         else
           let (topA :: restA as onA, onB, onC) = selectMove move s in
           permutate (match onB with
                      | []                           -> (restA, [topA], onC)
                      | topB :: _  when topB >= topA ->
                         match less topA topB with
                         | true -> (restA, topA :: onB, onC)
                     ) move)
