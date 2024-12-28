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
  static function cheatExits(grid:Array<String>, from:Point, cheatLen:Int):Array<WeightedPoint> {
    final size = grid.length;

    final visited = new Map<Int, Bool>();
    visited.set(from.r * size + from.c, true);

    final exitPoints = new Array<WeightedPoint>();
    final q = new List<WeightedPoint>();
    q.add({r: from.r, c: from.c, d: 0});
    while (!q.isEmpty()) {
      final front = q.pop();
      if (front.d == cheatLen) {
        continue;
      }

      for (dir in directions) {
        final tr = front.r + dir.r;
        final tc = front.c + dir.c;
        final cell = grid[tr]?.charAt(tc);
        if (!visited.exists(tr * size + tc)) {
          if (cell == '#') {
            q.add({r: tr, c: tc, d: front.d + 1});
          } else if (cell == '.' || cell == 'E') {
            exitPoints.push({r: tr, c: tc, d: front.d + 1});
          }
          visited.set(tr * size + tc, true);
        }
      }
    }

    return exitPoints;
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
    var r = sr;
    var c = sc;
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
    for (i => from in path.keyValueIterator()) {
      for (exitPoint in cheatExits(grid, from, 2)) {
        final l = exitPoint.d;
        final j = dist[exitPoint.r * size + exitPoint.c];
        if (j - l - i >= THRESHOLD) {
          puzzle1++;
        }
      }
    }
    Sys.println('Puzzle 1: $puzzle1');

    var puzzle2 = 0;
    for (i => from in path.keyValueIterator()) {
      for (exitPoint in cheatExits(grid, from, 20)) {
        final l = exitPoint.d;
        final j = dist[exitPoint.r * size + exitPoint.c];
        if (j - l - i >= THRESHOLD) {
          puzzle2++;
        }
      }
    }
    Sys.println('Puzzle 2: $puzzle2');
  }
}
