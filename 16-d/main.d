import std.string;
import std.typecons;
import std.container.binaryheap;
import std.stdio : writeln, write, readln;
import std.algorithm.comparison : min;
import std.algorithm : canFind;
import std.container : DList;

alias Point = Tuple!(int, int);                             // (r, c)
alias DirectedPoint = Tuple!(int, int, int);                // (r, c, dir)
alias WeightedDirectedPoint = Tuple!(int, int, int, int);   // (r, c, dir, weight)

int posmod(int a, int b) {
  int res = a % b;
  return (res < 0) ? (res + b) : res;
}

void main() {
  string line;
  string[] grid;
  while ((line = readln.chomp) !is null) {
    grid ~= line;
  }

  int sr, sc;
  int er, ec;
  foreach (r, string row; grid) {
    foreach (c, char cell; row) {
      if (cell == 'S') {
        sr = cast(int) r;
        sc = cast(int) c;
      } else if (cell == 'E') {
        er = cast(int) r;
        ec = cast(int) c;
      }
    }
  }

  int rows = cast(int) grid.length;
  int cols = cast(int) grid[0].length;

  Tuple!(int, int)[4] directions = [tuple(0, 1), tuple(1, 0), tuple(0, -1), tuple(-1, 0)];
  WeightedDirectedPoint[][DirectedPoint] adj;
  
  foreach (ri, string row; grid) {
    int r = cast(int) ri;
    foreach (ci, char cell; row) {
      int c = cast(int) ci;
      if (cell == '#') {
        continue;
      } 

      foreach (int d; 0 .. 4) {
        // get possible directions and weights, given current direction
        foreach (dw; [tuple(d, 1), tuple(posmod(d + 1, 4), 1001), tuple(posmod(d - 1, 4), 1001)]) {
          int ad = dw[0];
          int weight = dw[1];

          auto deltas = directions[ad];
          int tr = r + deltas[0];
          int tc = c + deltas[1];
          if (0 <= tr && tr < rows && 0 <= tc && tc < cols && grid[tr][tc] != '#') {
            adj.require(tuple(r, c, d)) ~= tuple(tr, tc, ad, weight);
          }
        }
      }
    }
  }

  int[DirectedPoint] dist;
  shortestDistances(sr, sc, 0, dist, adj);

  int endDist = int.max;
  int endDirection = 0;
  foreach (int d; 0 .. 4) {
    int currDist = dist.get(tuple(er, ec, d), int.max);
    if (currDist < endDist) {
      endDist = currDist;
      endDirection = (d + 2) % 4;
    }
  }
  writeln("Puzzle 1: ", endDist);

  int[DirectedPoint] revDist;
  shortestDistances(er, ec, endDirection, revDist, adj);

  int[200][200] merged = int.max;
  foreach (ri, string row; grid) {
    int r = cast(int) ri;
    foreach (ci, char cell; row) {
      int c = cast(int) ci;
      if (cell == '#') {
        continue;
      }

      int minForward = int.max, minReverse = int.max;
      foreach (int d; 0 .. 4) {
        minForward = min(minForward, dist.get(tuple(r, c, d), int.max));
        minReverse = min(minReverse, revDist.get(tuple(r, c, d), int.max));
      }
      merged[r][c] = minForward + minReverse;
    }
  }

  bool[Point] bestCells;
  auto q = DList!(Point[])([[tuple(sr, sc)]]);
  while (!q.empty()) {
    auto path = q.front();
    q.removeFront();
    int r = path[path.length - 1][0];
    int c = path[path.length - 1][1];
    if (r == er && c == ec) {
      foreach (Point p; path) {
        bestCells[p] = true;
      }
      continue;
    }

    foreach (Tuple!(int, int) dir; directions) {
      int tr = r + dir[0];
      int tc = c + dir[1];
      if (
        0 <= tr && tr < rows && 0 <= tc && tc < cols &&
        grid[tr][tc] != '#' && merged[tr][tc] <= endDist && !path.canFind(tuple(tr, tc))
      ) {
        q.insertBack(path ~ tuple(tr, tc));
      }
    }
  }

  writeln("Puzzle 2: ", bestCells.length);
}


void shortestDistances(
  int sr, int sc, int sd,
  ref int[DirectedPoint] dist,
  ref WeightedDirectedPoint[][DirectedPoint] adj
) {
  dist[tuple(sr, sc, sd)] = 0;

  auto pq = heapify!"a > b"([tuple(0, sr, sc, sd)]);
  while (!pq.empty()) {
    auto front = pq.front();
    pq.removeFront();

    int score = front[0], r = front[1], c = front[2], d = front[3];
    foreach (WeightedDirectedPoint adjPoint; adj.get(tuple(r, c, d), [])) {
      int tr = adjPoint[0], tc = adjPoint[1], ad = adjPoint[2], weight = adjPoint[3];
      if (score + weight <= dist.get(tuple(tr, tc, ad), int.max)) {
        dist[tuple(tr, tc, ad)] = score + weight;
        pq.insert(tuple(score + weight, tr, tc, ad));
      }
    }
  }
}
