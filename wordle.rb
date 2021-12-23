require "set"

class Wordle
  CORRECT   = "\e[0;42;30m"
  MISPLACED = "\e[0;43;30m"
  ABSENT    = "\e[0;40;37m"
  RESET     = "\e[0m"

  def initialize(dictionary)
    @dictionary = Set.new(dictionary)
  end

  def prompt(number)
    loop do
      $stdout.printf format("Guess %d/6 > ", number)
      $stdout.flush
      guess = gets.chomp.upcase
      return guess if @dictionary.include?(guess)

      $stdout.puts "Word not in dictionary"
    end
  end

  def play
    word = @dictionary.to_a.sample

    (1..6).each do |round|
      guess = prompt(round)
      put_guess guess, word

      if guess == word
        $stderr.puts format("Correct answer in %d/6", round)
        return
      end
    end

    puts word
  end

  def put_guess(guess, word)
    guess.chars.zip(word.chars).each do |g, w|
      if g == w
        $stdout.print CORRECT
      elsif word.include?(g)
        $stdout.print MISPLACED
      else
        $stdout.print ABSENT
      end

      $stdout.print g, RESET
    end
    $stdout.puts
  end
end


words = File.read("5.txt").chomp.split(/\n/)
Wordle.new(words).play
