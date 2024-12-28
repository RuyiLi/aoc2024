import haxe.iterators.StringIterator;

typedef Point = {r:Int, c:Int}
typedef WeightedPoint = Point & {d: Int}

final THRESHOLD = 100;

final directions: Array<Point> = [
  {r: 1, c: 0},
  {r: 0, c: 1},
  {r: -1, c: 0},
  {r: 0, c: -1},
];

class Main {
  static function countReachable(
    grid:Array<String>,
    dist:Array<Int>,
    from:Point,
    cheatLen:Int,
  ): Int {
    final size = grid.length;
    final sr = from.r, sc = from.c;
    final sd = dist[sr * size + sc];

    // find exact manhat diamond because getting the square and filtering after is boring
    var count = 0;
    for (mdist in 1...(cheatLen + 1)) {
      // diamond border for each manhattan distance in [1, cheatLen]
      for (offset in 0...mdist) {
        var dr = mdist - offset;
        var dc = offset;
        for (_quadrant in 0...4) {
          final r = sr + dr;
          final c = sc + dc;
          final cell = grid[r]?.charAt(c);
          final timeSaved = (dist[r * size + c] ?? 0) - sd - mdist;
          if (timeSaved >= THRESHOLD && (cell == '.' || cell == 'E')) {
            count++;
          }

          // rotate
          final dx = dc;
          dc = dr;
          dr = -dx;
        }
      }
    }
    return count;
  }

  static public function main():Void {
    var line:String;
    var grid = new Array<String>();
    try {
      while (true) {
        line = Sys.stdin().readLine();
        grid.push(line);
      }
    } catch (e:haxe.io.Eof) {
      trace("done!");
    }

    final size = grid.length;
    var sr = 0, sc = 0;
    var er = 0, ec = 0;

    for (r => row in grid.keyValueIterator()) {
      for (c in 0...size) {
        switch (row.charAt(c)) {
          case 'S':
            sr = r;
            sc = c;
          case 'E':
            er = r;
            ec = c;
        }
      }
    }

    final dist = [for (i in 0...(size * size)) -1];
    final path = new Array<Point>();

    // first pass to find path
    var r = sr, c = sc;
    var d = 0;
    while (true) {
      path.push({r: r, c: c});
      dist[r * size + c] = d;
      if (r == er && c == ec) {
        break;
      }
      for (dir in directions) {
        final tr = r + dir.r;
        final tc = c + dir.c;
        final cell = grid[tr].charAt(tc);
        if (dist[tr * size + tc] == -1 && (cell == '.' || cell == 'E')) {
          r = tr;
          c = tc;
          d++;
          break;
        }
      }
    }
    
    var puzzle1 = 0;
    for (from in path) {
      puzzle1 += countReachable(grid, dist, from, 2);
    }
    Sys.println('Puzzle 1: $puzzle1');

    var puzzle2 = 0;
    for (from in path) {
      puzzle2 += countReachable(grid, dist, from, 20);
    }
    Sys.println('Puzzle 2: $puzzle2');
  }
}
