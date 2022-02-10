open GT

open OCanren
open OCanren.Std

open WaterPuzzle

(*************************************************)
module For_gnat = struct
  [%%distrib
    type nonrec 'a0 t = 'a0 WaterPuzzle.gnat =
    | O
    | S of 'a0
    [@@deriving gt ~options:{show; gmap}]
    type ground = ground t]
end

@type 'a gnat = 'a WaterPuzzle.gnat = O | S of 'a with show
@type nat     = nat gnat with show
@type lnat    = lnat gnat logic with show
@type move    = WaterPuzzle.gmove = AB | BA | FillA | FillB with show
@type set     = nat * nat * nat * nat with show
@type lset    = ocanren {lnat * lnat * lnat * lnat} with show
@type answer  = move OCanren.Std.List.ground with show

let rec toN n = if n = 0 then o () else s (toN (n - 1))

let _ =
  Printf.printf "Test!\n";
  Printf.printf "%s\n" @@
  show(answer) @@
  Stdlib.List.hd @@
  Stream.take ~n:1 @@
    run q (fun q -> ocanren {
                      fresh a, b, c, d in
                      eval_o ((===) (toN !(5), toN !(3), toN !(0), toN !(0))) ((===) q) (a, b, c, d) &
                      {c == toN !(1) | d == toN !(1)}
                    }) (fun rr -> rr#reify (Std.List.prj_exn prj_exn))
