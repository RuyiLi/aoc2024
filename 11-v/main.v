import os
import time
import arrays
import strconv

fn atou(s string) !u64 {
  return strconv.parse_uint(s, 10, 0)!
}

fn blink(n u64, mut memo map[u64]map[int]u64, times int) u64 {
  if n in memo && times in memo[n] {
    return memo[n][times]
  }

  if times == 0 {
    return 1
  }

  amount := match true {
    n == 0 { blink(1, mut memo, times - 1) }
    n.str().len % 2 == 0 { 
      s := n.str()
      m := int(s.len / 2)
      l := atou(s[..m]) or { panic("Failed to convert string $s") }
      r := atou(s[m..]) or { panic("Failed to convert string $s") }
      blink(l, mut memo, times - 1) + blink(r, mut memo, times - 1)
    }
    else { blink(n * 2024, mut memo, times - 1) }
  }

  memo[n][times] = amount
  return amount
}

fn main() {
  sw := time.new_stopwatch()

  stones := os.get_line().split(' ').map(atou(it)!)
  mut memo := map[u64]map[int]u64 {}

  puzzle_1_stones := stones.map(blink(it, mut memo, 25))
  total_1 := arrays.reduce(
    puzzle_1_stones,
    fn (acc u64, n u64) u64 { return acc + n }
  )!
  println("Puzzle 1: $total_1 (took ${sw.elapsed().milliseconds()} ms)")

  puzzle_2_stones := stones.map(blink(it, mut memo, 75))
  total_2 := arrays.reduce(
    puzzle_2_stones,
    fn (acc u64, n u64) u64 { return acc + n }
  )!
  println("Puzzle 2: $total_2 (took ${sw.elapsed().milliseconds()} ms)")
}
