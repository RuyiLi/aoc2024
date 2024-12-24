import Foundation
typealias Grid = Array<Array<Character>>

var origGrid = Grid()
while let line = readLine() {
  if line.isEmpty {
    break
  }
  let row = Array(line)
  origGrid.append(row)
}

var moves = ""
while let line = readLine() {
  moves += line
}

let directions = [
  Character("<"): (0, -1),
  Character("^"): (-1, 0),
  Character(">"): (0, 1),
  Character("v"): (1, 0),
]

func startPos(grid: inout Grid) -> (Int, Int) {
  for (r, row) in grid.enumerated() {
    if let idx = row.firstIndex(of: "@") {
      return (r, row.distance(from: row.startIndex, to: idx))
    }
  }
  return (-1, -1)
}

func freeDist(grid: inout Grid, _ r: Int, _ c: Int, _ dr: Int, _ dc: Int) -> Int {
  var dist = 1
  while true {
    let cell = grid[r + dr * dist][c + dc * dist]
    if cell == "#" {
      return 0
    }
    if cell == "." {
      return dist
    }
    dist += 1
  }
}

func puzzle1() {
  var grid = origGrid
  var (ar, ac) = startPos(grid: &grid)

  func makeMove(move: String.Element) {
    let (dr, dc) = directions[move]!
    let dist = freeDist(grid: &grid, ar, ac, dr, dc)
    if dist == 0 {
      return
    }

    grid[ar][ac] = "."
    grid[ar + dr][ac + dc] = "@"
    if dist > 1 {
      grid[ar + dr * dist][ac + dc * dist] = "O"
    }
    ar += dr
    ac += dc
  }
  
  moves.forEach(makeMove)
  
  var total = 0
  for (r, row) in grid.enumerated() {
    for (c, cell) in row.enumerated() {
      if cell == "O" {
        total += 100 * r + c
      }
    }
  }
  print("Puzzle 1: ", total)
}

func puzzle2() {
  var grid = Grid()
  for origRow in origGrid {
    var row = Array<Character>()
    for cell in origRow {
      if cell == "O" {
        row.append(contentsOf: "[]")
      } else if cell == "@" {
        row.append(contentsOf: "@.")
      } else {
        row.append(contentsOf: [cell, cell])
      }
    }
    grid.append(row)
  }
  var (ar, ac) = startPos(grid: &grid)
  let cols = grid[0].count

  // there's a decent amount of duplicated code but in the interest of time, they will remain duplicated
  func makeMove(move: String.Element) {
    let (dr, dc) = directions[move]!
    let dist = freeDist(grid: &grid, ar, ac, dr, dc)
    if dist == 0 {
      return
    }

    var didPush = true
    if dist > 1 {
      if dr == 0 {
        // horizontal movement
        for i in (2 ..< dist + 1).reversed() {
          grid[ar][ac + i * dc] = grid[ar][ac + i * dc - dc]
        }
      } else {
        // vertical movement
        var stack = Array<(Int, Int)>()
        if "[]".contains(grid[ar + dr][ac]) {
          stack.append((ar + dr, ac))
        }
        
        var seen = Set<Int>()
        var toPush = Array<(Int, Int)>()
        while !stack.isEmpty {
          let (r, c) = stack.popLast()!

          // enqueue vertically adjacent boxes
          let left = if grid[r][c] == "[" { c } else { c - 1 }
          let vAdjLeft = grid[r + dr][left]
          let vAdjRight = grid[r + dr][left + 1]
          
          if "[]".contains(vAdjLeft) { stack.append((r + dr, left)) }
          if vAdjRight == "[" { stack.append((r + dr, left + 1)) }
          if vAdjLeft == "#" || vAdjRight == "#" {
            toPush.removeAll()
            didPush = false
            break
          }

          // hash coordinate (flattened index)
          if !seen.contains(r * cols + c) {
            seen.insert(r * cols + c)
            toPush.append((r, c))
          }
        }

        // sort ascending (top down) if pushing up, else descending (bottom up)
        toPush.sort(by: { dr * $0.0 < dr * $1.0 })
        while !toPush.isEmpty {
          let (r, c) = toPush.popLast()!
          let left = if grid[r][c] == "[" { c } else { c - 1 }
          grid[r + dr][left] = "["
          grid[r + dr][left + 1] = "]"
          grid[r][left] = "."
          grid[r][left + 1] = "."
        }
      }
    }

    if didPush {
      grid[ar][ac] = "."
      grid[ar + dr][ac + dc] = "@"
      ar += dr
      ac += dc
    }
  }

  moves.forEach(makeMove)
  
  var total = 0
  for (r, row) in grid.enumerated() {
    for (c, cell) in row.enumerated() {
      if cell == "[" {
        total += 100 * r + c
      }
    }
  }
  print("Puzzle 2: ", total)
}

puzzle1()
puzzle2()
