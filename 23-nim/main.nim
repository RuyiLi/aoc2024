import std/sets
import std/tables
import std/sequtils
import std/strutils
import std/algorithm

var line: string
var connections = initTable[string, HashSet[string]]()
while readLine(stdin, line):
  let u = line[0..1]
  let v = line[3..4]
  connections.mgetOrPut(u, initHashSet[string]()).incl(v)
  connections.mgetOrPut(v, initHashSet[string]()).incl(u)

var total = 0
for u, vs in connections.mpairs():
  for v in vs:
    if u > v:
      continue
    for w in connections[v]:
      if v > w or not (u in connections[w]):
        continue
      if 't' in [u[0], v[0], w[0]]:
        total += 1
echo "Puzzle 1: ", total

# bron-kerbosch
var cliques: seq[HashSet[string]] = @[]
proc findMaximalCliques(r: HashSet[string], p: HashSet[string], x: HashSet[string]) =
  if len(p) == 0 and len(x) == 0:
    cliques.add(r)
    return

  var currP = p.toSeq().toHashSet()
  var currX = x.toSeq().toHashSet()
  for v in p.items():
    findMaximalCliques(r + [v].toHashSet(), currP * connections[v], currX * connections[v])
    currP.excl(v)
    currX.incl(v)

let keys = connections.keys().toSeq().toHashSet()
findMaximalCliques(initHashSet[string](), keys, initHashSet[string]())

var maxLen = 0
var maxClique: HashSet[string]
for clique in cliques:
  if len(clique) > maxLen:
    maxLen = len(clique)
    maxClique = clique

var res = maxClique.toSeq()
res.sort()
echo "Puzzle 2: ", res.join(",")
