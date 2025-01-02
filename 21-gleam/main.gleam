import gleam/io
import gleam/int
import gleam/bool
import gleam/pair
import gleam/list
import gleam/dict.{type Dict}
import gleam/string
import gleam/erlang
import gleam/result

type Coord = #(Int, Int)
type Keypad = List(#(String, Coord))
type Cache = Dict(#(Int, Coord, Coord), Int)

const int_max: Int = 9223372036854775807
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

fn seq_cost(
  cache: Cache,
  code: String,
  code_keypad: Keypad,
  robot: Int,
  num_robots: Int,
) -> #(Int, Cache) {
  use <- bool.guard(code == "", #(1, cache))

  let keypad = dict.from_list(code_keypad)
  let coords_res = 
    string.append("A", code)
    |> string.to_graphemes()
    |> list.map(fn (c) { dict.get(keypad, c) })
    |> result.all()

  case coords_res {
    Ok(coords) -> {
      let #(cache, costs) = 
        coords
        |> list.window_by_2()
        |> list.map_fold(cache, fn (cache, pair) {
          let #(cost, cache) = move_cost(cache, robot - 1, pair.0, pair.1, num_robots)
          #(cache, cost)
        })
      #(costs |> int.sum(), cache)
    }
    Error(_) -> {
      io.debug("Failed to parse coords")
      #(0, cache)
    }
  }
}

fn move_cost(cache: Cache, robot: Int, from: Coord, to: Coord, num_robots: Int) -> #(Int, Cache) {
  let cache_key = #(robot, from, to)
  use <- bool.guard(
    dict.has_key(cache, cache_key),
    #(dict.get(cache, cache_key) |> result.unwrap(0), cache),
  )

  let #(sx, sy) = from
  let #(ex, ey) = to
  let dx = ex - sx
  let dy = ey - sy

  let adx = int.absolute_value(dx)
  let ady = int.absolute_value(dy)
  use <- bool.guard(
    robot == 0,
    #(adx + ady + 1, dict.insert(cache, cache_key, adx + ady + 1))
  )

  let h_seq = case dx > 0 {
    True -> ">"
    False -> "<"
  } |> string.repeat(adx)
  
  let v_seq = case dy > 0 {
    True -> "v"
    False -> "^"
  } |> string.repeat(ady)

  let edge_y = case robot == num_robots - 1 {
    True -> 3
    False -> 0
  }

  let h_prio_seq = string.concat([h_seq, v_seq, "A"])
  let v_prio_seq = string.concat([v_seq, h_seq, "A"])

  let #(h_cost, h_cache) = case #(ex, sy) == #(0, edge_y) {
    True -> #(int_max, cache)
    False -> seq_cost(cache, h_prio_seq, arrow_keypad, robot, num_robots)
  }

  let #(v_cost, v_cache) = case #(sx, ey) == #(0, edge_y) {
    True -> #(int_max, cache)
    False -> seq_cost(cache, v_prio_seq, arrow_keypad, robot, num_robots)
  }

  case h_cost < v_cost {
    True -> #(h_cost, dict.insert(h_cache, cache_key, h_cost))
    False -> #(v_cost, dict.insert(v_cache, cache_key, v_cost))
  }
}

fn complexity(codes: List(String), num_robots: Int) -> Int {
  codes
  |> list.map_fold(dict.new(), fn (cache, code) {
    let code_num =
      string.drop_end(code, 1)
      |> int.parse()
      |> result.unwrap(0)

    let #(cost, cache) = seq_cost(cache, code, num_keypad, num_robots, num_robots)
    #(cache, cost * code_num)
  })
  |> pair.second()
  |> int.sum()
}

pub fn main() {
  let codes = 
    list.range(1, 5)
    |> list.map(fn (_) {
      erlang.get_line("")
      |> result.unwrap("")
      |> string.trim()
    })
  
  let puzzle1 = complexity(codes, 3) |> int.to_string()
  string.append("Puzzle 1: ", puzzle1)
  |> io.println()

  let puzzle2 = complexity(codes, 26) |> int.to_string()
  string.append("Puzzle 2: ", puzzle2)
  |> io.println()
}
