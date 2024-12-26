use "buffered"
use "collections"
use pcoll = "collections/persistent"

actor Tracker
  let _env: Env
  let _total: USize
  var _bad: USize = 0
  var _good: USize = 0

  new create(env: Env, total: USize) => 
    _env = env
    _total = total

  be track(good: Bool) =>
    if good then
      _good = _good + 1
    else 
      _bad = _bad + 1
    end

    if (_good + _bad) == _total then
      _env.out.print("Puzzle 1: " + _good.string())
    end

actor Puzzle1
  let _tracker: Tracker
  let _patterns: pcoll.HashSet[String, HashByteSeq] val
  let _design: String
  let _env: Env
  var _n: ISize = 0
  var _memo: pcoll.HashMap[ISize, Bool, HashEq[ISize]] = _memo.create()

  new create(
    tracker: Tracker,
    patterns: pcoll.HashSet[String, HashByteSeq] val,
    design: String val, env: Env
  ) =>
    _tracker = tracker
    _patterns = patterns
    _design = design
    _env = env

    // directly using _design.isize() fails for some reason
    _n = _design.size().isize()
  
  // note: if this isn't fast enough, the cycle detector will assume it's blocked and kill it
  // meaning we'll have at least one missing actor and the tracker will never complete.
  // there is almost definitely a better way of doing this that i don't have the time to figure out
  be work() =>
    let res = _attempt_design(0)
    _tracker.track(res)

  fun ref _attempt_design(offset: ISize): Bool =>
    if offset >= _n then
      return true
    end

    if _memo.contains(offset) then
      return _memo.get_or_else(offset, false)
    end

    var right = offset + 1
    while (right <= (offset + 8)) and (right <= _n) do
      let substr = _design.substring(offset, right)
      if _patterns.contains(consume substr) then
        if _attempt_design(right) then
          _memo = _memo.update(offset, true)
          return true
        end
      end
      right = right + 1
    end

    _memo = _memo.update(offset, false)
    false

class Notify is InputNotify
  let _env: Env
  let _designs: Array[String] = _designs.create()
  var _patterns_str: String = _patterns_str.create()

  new create(env: Env) =>
    _env = env
    
  fun ref apply(data: Array[U8] iso) =>
    let reader = Reader
    reader.append(consume data)
    try
      if _patterns_str.size() == 0 then
        _patterns_str = reader.line()?
        reader.line()?
      end
      while true do
        let line = reader.line()?
        _designs.push(consume line)
      end
    end

  fun ref dispose() =>
    var patterns: pcoll.HashSet[String, HashByteSeq] = patterns.create()
    for pattern in _patterns_str.split_by(", ").values() do
      patterns = patterns.add(pattern)
    end
    let tracker = Tracker(_env, _designs.size())
    for design in _designs.values() do
      Puzzle1(tracker, patterns, design, _env).work()
    end

actor Main
  new create(env: Env) =>
    // need to read patterns in a single chunk
    env.input(recover Notify(env) end, 4096)
