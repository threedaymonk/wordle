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
    $stdout.printf format("Guess %d/%d > ", round, @rounds)
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
