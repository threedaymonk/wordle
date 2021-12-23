require "benchmark"
require_relative "./wordle"
require_relative "./robot"

devnull = File.open("/dev/null", "w")
words = File.read("5.txt").chomp.split(/\n/)
player = Robot.new(words, output: devnull)
wordle = Wordle.new(words)

n = 1000
results = []

Benchmark.benchmark do |bm|
  bm.report do
    n.times do |i|
      results << wordle.play(player)
    end
  end
end

aggregated = Hash.new { |h,k| h[k] = 0 }
results.each do |r|
  aggregated[r] += 1
end

aggregated.sort_by { |a| a.first || 0 }.each do |k, v|
  key = k ? k.to_s : "F"
  printf "%s: %d%%\n", key, (v * 100.0 / n).round
end
