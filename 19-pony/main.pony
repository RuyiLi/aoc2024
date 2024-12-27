use "buffered"
use "collections"

actor Tracker
  let _env: Env
  let _total: USize
  var _bad: USize = 0
  var _good: USize = 0
  var _ways: USize = 0

  new create(env: Env, total: USize) => 
    _env = env
    _total = total

  be track(count: USize) =>
    _ways = _ways + count
    if count > 0 then
      _good = _good + 1
    else 
      _bad = _bad + 1
    end
    if (_good + _bad) == _total then
      _env.out.print("Puzzle 1: " + _good.string())
      _env.out.print("Puzzle 2: " + _ways.string())
    end

actor Arranger
  let _tracker: Tracker
  let _patterns: HashSet[String, HashByteSeq] val
  let _design: String
  let _env: Env
  var _n: ISize = 0
  
  // _memo[K] = starting from offset K, how many ways to reach the end of the string
  var _memo: HashMap[ISize, USize, HashEq[ISize]] = _memo.create()

  new create(
    tracker: Tracker,
    patterns: HashSet[String, HashByteSeq] val,
    design: String val,
    env: Env
  ) =>
    _tracker = tracker
    _patterns = patterns
    _design = design
    _env = env

    // directly using _design.isize() fails for some reason
    _n = _design.size().isize()
  
  // note: if this isn't fast enough, the cycle detector will assume it's blocked and kill it
  //  meaning we'll have at least one missing actor and the tracker will never complete.
  // there is almost definitely a better way of doing this that i don't have the time to figure out
  // maybe by making work recursive? 
  // or by having an active variable here and sending a periodic ping from the main actor? 
  be work() =>
    _memo = HashMap[ISize, USize, HashEq[ISize]]
    _attempt_design(0)
    _tracker.track(_memo.get_or_else(0, 0))

  fun ref _attempt_design(offset: ISize) =>
    if (offset == _n) or _memo.contains(offset) then
      return
    end

    var count: USize = 0
    for right in Range[ISize](offset + 1, _n.min(offset + 9) + 1) do
      let substr: String val = _design.substring(offset, right)
      if _patterns.contains(substr) then
        _attempt_design(right)
        let right_count = _memo.get_or_else(right, 1)
        count = count + right_count
      end
    end
    
    _memo.update(offset, count)
    
class Notify is InputNotify
  let _env: Env
  var _raw: String iso = _raw.create()

  new create(env: Env) =>
    _env = env
    
  fun ref apply(data: Array[U8] iso) =>
    // can't use the reader here because the chunk might end in the middle of a design
    _raw.append(consume data)

  fun ref dispose() =>
    // destructive read
    let tmp: String iso = tmp.create()
    let raw: String val = _raw = consume tmp

    let patterns: HashSet[String, HashByteSeq] iso = patterns.create()
    let designs: Array[String] = designs.create()

    let reader = Reader
    reader.append(raw)
    try
      for pattern in reader.line()?.split(", ").values() do
        patterns.set(pattern)
      end
      reader.line()?
      while true do
        let line = reader.line()?
        designs.push(consume line)
      end
    end

    let patterns_read: HashSet[String, HashByteSeq] val = consume patterns
    let tracker = Tracker(_env, designs.size())
    for design in designs.values() do
      Arranger(tracker, patterns_read, design, _env).work()
    end

actor Main
  new create(env: Env) =>
    // need to read patterns in a single chunk
    env.input(recover Notify(env) end, 2048)
