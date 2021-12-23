require "set"

class Robot
  COLORS = {
    correct:   "\e[0;42;30m",
    misplaced: "\e[0;43;30m",
    absent:    ""
  }
  RED = "\e[0;41;97m"

  RESET = "\e[0m"

  def initialize(dictionary)
    @dictionary = dictionary
    @letter_frequencies = Hash.new { |h, k| h[k] = 1 }
    @dictionary.each do |word|
      word.chars.each do |char|
        @letter_frequencies[char] += 1
      end
    end
  end

  def begin(rounds, length)
    @rounds = rounds
    @length = length
    @possible = length.times.map { ("A".."Z").to_a }
    @guessed_words = Set.new
    @guessed_letters = Set.new
    @required_letters = Set.new
    @possible_letters = Set.new(("A".."Z").to_a)
  end

  def guess(round)
    @guess =
      if round == 6 || possible_words.length < 3
        most_plausible
      else
        most_informative
      end

    @guessed_words << @guess

    @guess.chars.each do |char|
      @guessed_letters << char
    end

    @guess
  end

  def warn(message)
    $stdout.puts message
  end

  def respond(round, response)
    @guess.chars.zip(response).each.with_index do |(char, status), i|
      case status
      when :correct
        @required_letters << char
        @possible[i] = [char]
      when :absent
        @possible_letters.delete char
        @possible.each do |ary|
          ary.delete char
        end
      when :misplaced
        @required_letters << char
        @possible[i].delete char
      end

      $stdout.print COLORS[status], char, RESET
    end
    $stdout.puts
  end

  def win(round)
    $stderr.puts format("Correct answer in %d/%d", round, @rounds)
  end

  def lose(word)
    $stderr.puts "#{RED}#{word}#{RESET}"
  end

  def inspect
    "#<Robot:#{object_id}>"
  end

private

  def possible_words
    regexp = Regexp.new(
      "^" + @possible.map { |a| "[" + a.join("") + "]" }.join + "$"
    )
    @dictionary
      .select { |w| w =~ regexp }
      .reject { |w| @guessed_words.include?(w) }
      .select { |w| @required_letters.to_a.all? { |a| w.include?(a) } }
  end

  def most_plausible
    possible_words
      .tap { |a| p a }
      .map { |w| [w, (w.chars.uniq - @guessed_letters.to_a).length] }
      .sort_by(&:last)
      .last
      .first
  end

  def most_informative
    regexp = Regexp.new(
      "^" + ("[" + @possible_letters.to_a.join("") + "]") * @length + "$"
    )
    @dictionary
      .select { |w| w =~ regexp }
      .reject { |w| @guessed_words.include?(w) }
      .map { |w| [
        w,
        (w.chars.uniq - @guessed_letters.to_a).map { |c|
          @letter_frequencies[c]
        }.inject(0, &:+)
      ] }
      .sort_by(&:last)
      .last
      .first
  end
end

require_relative "./wordle"
words = File.read("5.txt").chomp.split(/\n/)
player = Robot.new(words)
wordle = Wordle.new(words)

results = []
1000.times do |i|
  puts "Round #{i}"
  results << wordle.play(player)
end

aggregated = Hash.new { |h,k| h[k] = 0 }
results.each do |r|
  aggregated[r] += 1
end

p aggregated
