#load "str.cma" ;;

type wiremap = (string, bool) Hashtbl.t
type gatedef = { op: string; a: string; b: string; out: string }

exception Invalid_gate ;;
exception Invalid_operation ;;

(* Mutates wires *)
let rec read_wires (wires : wiremap) : wiremap =
  let line = read_line() in
  match Str.split (Str.regexp ": ") line with
  | [w; v] ->
    Hashtbl.add wires w (String.equal v "1") ;
    read_wires wires 
  | _ -> wires ;;

let rec read_gates (gates : gatedef list) : gatedef list =
  try
    let line = read_line() in
    match String.split_on_char ' ' line with
    | [a; op; b; _arrow; out] ->
      read_gates ({ op = op; a = a; b = b; out = out } :: gates)
    | _ -> raise Invalid_gate ;
  with End_of_file -> gates ;;

let do_op (op : string) (a : bool) (b : bool) =
  match op with
  | "AND" -> a && b
  | "OR" -> a || b
  | "XOR" -> a <> b
  | _ -> raise Invalid_operation ;;

(* Mutates wires. Returns whether to keep the gate. *)
let maybe_evaluate_gate (wires : wiremap) (gate : gatedef) : bool =
  match (Hashtbl.find_opt wires gate.a, Hashtbl.find_opt wires gate.b) with
  | (Some a, Some b) ->
    let res = do_op gate.op a b in
    Hashtbl.add wires gate.out res ;
    false
  | _ -> true ;;

(* Mutates wires *)
let rec evaluate_gates (wires : wiremap) (gates : gatedef list) : unit =
  match gates with
  | [] -> ()
  | _ ->
    let new_gates = List.filter (maybe_evaluate_gate wires) gates in
    evaluate_gates wires new_gates ;;

let wire_num (prefix : string) (wire : string) (value : bool) (acc : int) : int =
  if value && (String.starts_with ~prefix:prefix wire) then
    let exp = int_of_string (String.sub wire 1 2) in
    acc + Int.shift_left 1 exp
  else acc ;;

let full_wire_num (prefix : string) (wires : wiremap) : int =
  Hashtbl.fold (wire_num prefix) wires 0 ;;

let rec indent (level : int) (acc : string) : string =
  if level == 0 then acc
  else indent (level - 1) (acc ^ " ")

(*
  All wires (excepting 1, 2, and 45) have a evaluation tree with the below form:

                     zYY
                /           \
             AAA     XOR     BBB
         /        \         /   \
      CCC    OR    DDD   xYY XOR yYY   
     /   \        /   \
  EEE AND FFF  xXX AND yXX

  where - YY is the current output wire number, and XX is the previous one (YY - 1).
        - EEE/FFF are the AAA/BBB of the previous wire (zXX = EEE XOR FFF).
  Our goal is to find trees that do not follow this form.
  This makes the assumption that the system of input gates is formed optimally (i.e. they all have this form).
  Since there are only 4 pairs of gates, it's faster to just inspect/fix manually.
  Hence, this program won't actually print out the answer.
*)
let rec print_gate_deps (gates : gatedef list) (level : int) (target : string) : unit =
  if level <= 3 then (
    Printf.printf "%s%s" (indent level "") target ;
    match List.find_opt (fun g -> String.equal g.out target) gates with
    | Some el ->
      Printf.printf " %s\n" el.op ;
      print_gate_deps gates (level + 1) el.a ;
      print_gate_deps gates (level + 1) el.b
    | None -> Printf.printf "\n"
  ) ;;

let () =
  let wires = read_wires (Hashtbl.create 128) in
  let gates = read_gates [] in
  evaluate_gates wires gates ;
  let puzzle1 = full_wire_num "z" wires in
  Printf.printf "Puzzle 1: %d\n" puzzle1 ;
  Printf.printf "Puzzle 2: \n" ;
  gates 
  |> List.map (fun g -> g.out)
  |> List.filter (String.starts_with ~prefix:"z")
  |> List.sort String.compare
  |> List.iter (print_gate_deps gates 0) ;
  let x = full_wire_num "x" wires in
  let y = full_wire_num "y" wires in
  Printf.printf "     x: %d\n" x ;
  Printf.printf "     y: %d\n" y ;
  Printf.printf "Expect: %d\n" (x + y) ;
  Printf.printf "Actual: %d\n" puzzle1;
  Printf.printf "Match?: %b\n" (x + y == puzzle1) ;;
