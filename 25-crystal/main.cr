WIDTH = 5
HEIGHT = 7

locks = Array(Array(Int32)).new
keys = Array(Array(Int32)).new

def to_heights(lines)
  heights = Array(Int32).new(WIDTH, -1)
  lines.each do |line|
    line.chars.each.with_index do |c, i|
      heights[i] += (c == '#').to_unsafe
    end
  end
  heights
end

until STDIN.peek.empty? 
  lines = Array(String).new(HEIGHT) { STDIN.gets.not_nil! }
  heights = to_heights(lines)
  if lines[0].count("#") == WIDTH
    locks.push(heights)
  else
    keys.push(heights)
  end
  STDIN.gets
end

total = 0
locks.each do |lock|
  keys.each do |key|
    res = lock.zip(key).all? { |l, k| l + k < HEIGHT - 1 }
    total += res.to_unsafe
  end
end
puts "Answer: #{total}"
