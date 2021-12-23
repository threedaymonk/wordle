require "set"

class Wordle
  ROUNDS = 6
  LENGTH = 5

  def initialize(dictionary)
    @dictionary = Set.new(dictionary)
  end

  def play(player)
    word = @dictionary.to_a.sample
    player.begin ROUNDS, LENGTH

    (1..ROUNDS).each do |round|
      guess = nil
      loop do
        guess = player.guess round
        break if @dictionary.include?(guess)

        player.warn "Word not in dictionary"
      end

      player.respond round, build_response(guess, word)
      if guess == word
        player.win round
        return
      end
    end

    player.lose word
  end

  def build_response(guess, word)
    guess.chars.zip(word.chars).map { |g, w|
      if g == w
        :correct
      elsif word.include?(g)
        :misplaced
      else
        :absent
      end
    }
  end

  def inspect
    "#<Wordle:#{object_id}>"
  end
end

class CLI
  COLORS = {
    correct:   "\e[0;42;30m",
    misplaced: "\e[0;43;30m",
    absent:    "\e[0;40;37m"
  }

  RESET = "\e[0m"

  def begin(rounds, length)
    @rounds = rounds
    @length = length
  end

  def guess(round)
    $stdout.printf format("Guess %d/6 > ", round)
    $stdout.flush
    @guess = gets.chomp.upcase
  end

  def warn(message)
    $stdout.puts message
  end

  def respond(round, response)
    @guess.chars.zip(response).each do |char, status|
      $stdout.print COLORS[status], char, RESET
    end
    $stdout.puts
  end

  def win(round)
    $stderr.puts format("Correct answer in %d/%d", round, @rounds)
  end

  def lose(word)
    $stderr.puts word
  end
end

words = File.read("5.txt").chomp.split(/\n/)
player = CLI.new
Wordle.new(words).play(player)
