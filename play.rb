require_relative "./wordle"
require_relative "./cli"

words = File.read("5.txt").chomp.split(/\n/)
player = CLI.new
Wordle.new(words).play(player)
