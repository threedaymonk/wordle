# frozen_string_literal: true

require "set"

class Robot
  COLORS = {
    correct:   "\e[0;42;30m",
    misplaced: "\e[0;43;30m",
    absent:    ""
  }
  RED = "\e[0;41;97m"

  RESET = "\e[0m"

  def initialize(dictionary, output: $stdout)
    @output = output
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
      case round
      when 1
        "CLEAN"
      when 2
        "RIOTS"
      when 6
        most_plausible
      else
        possible_words.length < 4 ? most_plausible : most_informative
      end

    @guessed_words << @guess

    @guess.chars.each do |char|
      @guessed_letters << char
    end

    @guess
  end

  def warn(message)
    raise message
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

      @output.print COLORS[status], char, RESET
    end
    @output.puts
    @__possible_words = nil
  end

  def win(round)
    @output.printf "Correct answer in %d/%d\n", round, @rounds
  end

  def lose(word)
    @output.puts "#{RED}#{word}#{RESET}"
  end

  def inspect
    "#<Robot:#{object_id}>"
  end

private

  def possible_words
    @__possible_words ||= (
      possible_re = Regexp.new(
        "^" + @possible.map { |a| "[" + a.join("") + "]" }.join + "$"
      )
      @dictionary
        .select { |w| w =~ possible_re }
        .reject { |w| @guessed_words.include?(w) }
        .select { |w| @required_letters.all? { |a| w.include?(a) } }
    )
  end

  def most_plausible
    possible_words
      .map { |w| [w, (w.chars.uniq - @guessed_letters.to_a).length] }
      .sort_by(&:last)
      .last
      .first
  end

  def most_informative
    use_available_letters = Regexp.new(
      "^" + ("[" + @possible_letters.join("") + "]") * @length + "$"
    )
    @dictionary
      .select { |w| w =~ use_available_letters }
      .reject { |w| @guessed_words.include?(w) }
      .map { |w| [
        w,
        (w.chars.uniq - @guessed_letters.to_a).inject(0) { |a, c|
          a + @letter_frequencies[c]
        }
      ] }
      .sort_by(&:last)
      .last
      .first
  end
end
