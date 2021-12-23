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
    printf "Guess %d/%d > ", round, @rounds
    flush
    @guess = gets.chomp.upcase
  end

  def warn(message)
    puts message
  end

  def respond(round, response)
    @guess.chars.zip(response).each do |char, status|
      print COLORS[status], char, RESET
    end
    puts
  end

  def win(round)
    puts format("Correct answer in %d/%d", round, @rounds)
  end

  def lose(word)
    puts word
  end

private

  def flush
    $stdout.flush
  end
end
