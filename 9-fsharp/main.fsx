open System

let stopWatch = System.Diagnostics.Stopwatch.StartNew()

let idNum idx =
  if idx % 2 = 0 then idx / 2 else 0

let disk =
  Console.ReadLine()
  |> Seq.map (fun c -> uint64 c - uint64 '0')
  |> Seq.indexed
  |> Seq.map (fun (i, x) -> (uint64 (idNum i), x))
  |> Seq.toList

// sum [rangeStart, rangeEnd)
let sumRange (rangeStart: uint64) (rangeEnd: uint64) =
 (rangeEnd - rangeStart) * (rangeStart + rangeEnd - 1UL) / 2UL

// puzzle1 expandedIndex totalChecksum diskDefinition isCurrEmpty
let rec puzzle1 (idx: uint64) (total: uint64) (empty: bool) = function
  | (lId, lBlocks) :: tail ->
    if empty then
      match List.rev tail with
      | (rId, rBlocks) :: mids ->
        let endIdx = idx + min rBlocks lBlocks
        let remaining =
          if rBlocks > lBlocks then List.rev ((rId, rBlocks - lBlocks) :: mids)
          elif rBlocks = lBlocks then List.tail mids |> List.rev
          else (0UL, lBlocks - rBlocks) :: (List.tail mids |> List.rev)
        puzzle1 endIdx (total + rId * sumRange idx endIdx) (rBlocks < lBlocks) remaining
      | _ -> total
    else
      let endIdx = idx + lBlocks
      puzzle1 endIdx (total + lId * sumRange idx endIdx) true tail
  | _ -> total

// puzzle 2

type File = (uint64 * uint64 * uint64)

let rec disksWithIdxHelper disk idx acc =
  match disk with
  | (i, x) :: tail -> disksWithIdxHelper tail (idx + x) ((idx, i, x) :: acc)
  | _ -> List.rev acc

// (expandedIdx, fileId, numBlocks)
let disksWithIdx = disksWithIdxHelper disk 0UL [ ]

let collectAlternating lst =
  lst
  |> List.indexed
  |> List.filter (fun (i, _) -> i % 2 = 0)
  |> List.map snd

let diskEmpties =
  disksWithIdx
  |> List.tail
  |> collectAlternating

let diskFiles =
  disksWithIdx
  |> List.rev
  |> collectAlternating

let findEmpty (empties: File list) ((bIdx, _, tBlocks): File) =
  empties
  |> List.tryFindIndex (fun (idx, _, blocks) -> tBlocks <= blocks && bIdx >= idx)

let rec puzzle2 (files: File list) (added: File list) (skipped: File list) (empties: File list) =
  match files with
  | file :: tail ->
    let (idx, id, blocks) = file
    match findEmpty empties file with
    | Some(i) ->
      let (eIdx, _, eBlocks) = List.item i empties
      let step = puzzle2 tail ((eIdx, id, blocks) :: added) skipped
      if blocks = eBlocks then
        step (List.removeAt i empties) 
      else
        step (List.updateAt i (eIdx + blocks, 0UL, eBlocks - blocks) empties) 
    | None -> puzzle2 tail added (file :: skipped) empties
  | _ ->
    (0UL, skipped @ added)
    ||> List.fold  (fun acc (idx, id, blocks) -> acc + id * sumRange idx (idx + blocks))

printfn "Puzzle 1: %d" (puzzle1 0UL 0UL false disk)
printfn "Puzzle 2: %d" (puzzle2 diskFiles [ ] [ ] diskEmpties)

stopWatch.Stop()
printfn "Took %fms" stopWatch.Elapsed.TotalMilliseconds
