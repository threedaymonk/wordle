# frozen_string_literal: true

require "bundler/setup"
require "benchmark"
require "progressbar"
require_relative "./wordle"
require_relative "./robot"

devnull = File.open("/dev/null", "w")
words = File.read("5.txt").chomp.split(/\n/)
player = Robot.new(words, output: devnull)
wordle = Wordle.new(words)

SAMPLES = (ARGV[0] || "1000").to_i
results = []

Benchmark.benchmark do |bm|
  bm.report do
    pb = ProgressBar.create(title: "Benchmarking", total: SAMPLES)
    SAMPLES.times do |i|
      results << wordle.play(player)
      pb.increment
    end
  end
end

aggregated = Hash.new { |h,k| h[k] = 0 }
results.each do |r|
  aggregated[r] += 1
end

aggregated.sort_by { |a| a.first || 0 }.each do |k, v|
  key = k ? k.to_s : "F"
  printf "%s: %2.2f%%\n", key, (v * 100.0 / SAMPLES)
end
