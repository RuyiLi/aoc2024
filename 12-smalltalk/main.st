"This solution is pretty cool, you should read it :)"

rawGrid := stdin contents substrings '\n'.
size := rawGrid size.

grid := OrderedCollection new.
rawGrid do: [ :rawRow |
  | row |
  row := OrderedCollection new.
  row addAll: rawRow.
  grid add: row.
].

at := [ :x :y |
  ( (1 <= x) & (x <= size) & (1 <= y) & (y <= size) )
    ifTrue: [ (grid at: y) at: x ]
    ifFalse: [ -1 ].
].

"Puzzle 1"
"Straightforward BFS. Precomputes areas for puzzle 2."

visited := Set new.
areas := Dictionary new.
adj := Array with: (0 @ 1) with: (0 @ -1) with: (1 @ 0) with: (-1 @ 0).

"Separate regions are not guaranteed to have separate identifiers."
"We maintain an autoincrementing ID to <paint over> a duplicate region,"
"so we can uniquely identify a region with its identifier."
aid := 0.

visit := [ :start |
  | queue paint target area perimeter |
  target := at value: (start x) value: (start y).

  "If we haven't visited this cell before, but the region ID already exists..."
  paint := target.
  ( areas includesKey: target )
    ifTrue: [
      paint := aid.
      aid := aid + 1.
    ].

  visited add: start.
  perimeter := 0.
  area := 1.

  queue := OrderedCollection new.
  queue addLast: start.
  [ queue size > 0 ]
    whileTrue: [
      | head |
      head := queue removeFirst.
      x := head x.
      y := head y.

      "Replace after finishing a visit."
      (grid at: y) at: x put: paint.

      adj do: [ :delta |
        | tx ty |
        tx := x + (delta x).
        ty := y + (delta y).
        ( ((at value: tx value: ty) == target) )
          ifTrue: [
            ( (visited includes: (tx @ ty)) not )
              ifTrue: [
                visited add: (tx @ ty).
                queue addLast: (tx @ ty).
                area := area + 1.
              ]
          ]
          ifFalse: [ perimeter := perimeter + 1 ].
      ].
    ].

  areas at: paint put: area.
  area * perimeter.
].

puzzle1 := 0.
1 to: size do: [ :y |
  1 to: size do: [ :x |
    ( (visited includes: (x @ y)) )
      ifFalse: [ puzzle1 := puzzle1 + (visit value: (x @ y)) ].
  ].
].
'Puzzle 1: ' display.
puzzle1 displayNl.

"Puzzle 2"
"We perform row-wise and column-wise scans, checking for existing edges by looking at a 2 by 2 box."
"Code for horizontal and vertical scans are mostly the same."
"XX"
"XY"

puzzle2 := 0.
edges := Dictionary new.
areas keys do: [ :k | edges at: k put: 0 ].

"Horizontal scans -- vertical edges"
1 to: size do: [ :y |
  | first last aboveFirst aboveLast |
  first := at value: 1 value: y.
  aboveFirst := at value: 1 value: (y - 1).
  ( first ~~ aboveFirst )
    ifTrue: [ edges at: first put: (edges at: first) + 1 ].

  last := at value: size value: y.
  aboveLast := at value: size value: (y - 1).
  ( last ~~ aboveLast )
    ifTrue: [ edges at: last put: (edges at: last) + 1 ].

  2 to: size do: [ :x |
    | curr prev |
    curr := at value: x value: y.
    prev := at value: (x - 1) value: y.

    ( curr ~~ prev )
      ifTrue: [
        | aboveCurr abovePrev |
        aboveCurr := at value: x value: (y - 1).
        abovePrev := at value: (x - 1) value: (y - 1).
        ( (abovePrev == prev) & (aboveCurr ~~ prev) )
          ifFalse: [ edges at: prev put: (edges at: prev) + 1 ].
        ( (aboveCurr == curr) & (abovePrev ~~ curr) )
          ifFalse: [ edges at: curr put: (edges at: curr) + 1 ].
      ].
  ].
].

"Vertical scans -- horizontal edges. Same logic as above."
1 to: size do: [ :x |
  | first last aleftFirst aleftLast |
  first := at value: x value: 1.
  aleftFirst := at value: (x - 1) value: 1.
  ( first ~~ aleftFirst )
    ifTrue: [ edges at: first put: (edges at: first) + 1 ].

  last := at value: x value: size.
  aleftLast := at value: (x - 1) value: size.
  ( last ~~ aleftLast )
    ifTrue: [ edges at: last put: (edges at: last) + 1 ].

  2 to: size do: [ :y |
    | curr prev |
    curr := at value: x value: y.
    prev := at value: x value: (y - 1).

    ( curr ~~ prev )
      ifTrue: [
        | aleftCurr aleftPrev |
        aleftCurr := at value: (x - 1) value: y.
        aleftPrev := at value: (x - 1) value: (y - 1).
        ( (aleftPrev == prev) & (aleftCurr ~~ prev) )
          ifFalse: [ edges at: prev put: (edges at: prev) + 1 ].
        ( (aleftCurr == curr) & (aleftPrev ~~ curr) )
          ifFalse: [ edges at: curr put: (edges at: curr) + 1 ].
      ].
  ].
].

puzzle2 := 0.
areas keysDo: [ :rid | puzzle2 := puzzle2 + ((areas at: rid) * (edges at: rid)) ].
'Puzzle 2: ' display.
puzzle2 displayNl.
