import gleam/io
import gleam/int
import gleam/list
import gleam/dict
import gleam/string
import gleam/erlang
import gleam/result

type Keypad = List(#(String, #(Int, Int)))

const num_keypad: Keypad = [
  #("7", #(0, 0)),
  #("8", #(1, 0)),
  #("9", #(2, 0)),
  #("4", #(0, 1)),
  #("5", #(1, 1)),
  #("6", #(2, 1)),
  #("1", #(0, 2)),
  #("2", #(1, 2)),
  #("3", #(2, 2)),
  #("0", #(1, 3)),
  #("A", #(2, 3)),
]

const arrow_keypad: Keypad = [
  #("^", #(1, 0)),
  #("A", #(2, 0)),
  #("<", #(0, 1)),
  #("v", #(1, 1)),
  #(">", #(2, 1)),
]

fn sequence(code: String, code_keypad: Keypad) -> String {
  let keypad = dict.from_list(code_keypad)

  string.append("A", code)
  |> string.to_graphemes()
  |> list.map(fn (c) { dict.get(keypad, c) |> result.unwrap(#(-1, -1)) })
  |> list.window_by_2()
  |> list.map(fn (pair) {
    let #(from, to) = pair
    let dx = to.0 - from.0
    let dy = to.1 - from.1

    let h_seq = case dx > 0 {
      True -> ">"
      False -> "<"
    } |> string.repeat(int.absolute_value(dx))

    let v_seq = case dy > 0 {
      True -> "v"
      False -> "^"
    } |> string.repeat(int.absolute_value(dy))

    let edge_y = case code_keypad == num_keypad {
      True -> 3
      False -> 0
    }

    case 1 {
      _ if from.0 == 0 && to.1 == edge_y ->
        string.append(h_seq, v_seq)
      _ if from.1 == edge_y && to.0 == 0 ->
        string.append(v_seq, h_seq)
      _ -> 
        case string.first(h_seq), string.first(v_seq) {
          Ok("<"), _ -> string.append(h_seq, v_seq)
          Ok(">"), Ok("^") -> string.append(h_seq, v_seq)
          Ok(">"), Ok("v") -> string.append(v_seq, h_seq) 
          Ok(_h), Error(_v) -> h_seq
          Error(_h), Ok(_v) -> v_seq
          _, _ -> ""
        }
    } |> string.append("A")
  })
  |> string.join("")
}

fn puzzle1(code: String) -> Int {
  let code_num =
    string.drop_end(code, 1)
    |> int.parse()
    |> result.unwrap(0)

  sequence(code, num_keypad)
  |> sequence(arrow_keypad)
  |> sequence(arrow_keypad)
  |> string.length()
  |> int.multiply(code_num)
}

pub fn main() {
  list.range(1, 5)
  |> list.map(fn (_) {
    erlang.get_line("")
    |> result.unwrap("")
    |> string.trim()
  })
  |> list.map(puzzle1)
  |> int.sum()
  |> io.debug()
}
