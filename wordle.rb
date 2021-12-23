# frozen_string_literal: true

require "set"

class Wordle
  ROUNDS = 6
  LENGTH = 5

  def initialize(dictionary)
    @dictionary = Set.new(dictionary)
  end

  def play(player, word = nil)
    word ||= @dictionary.to_a.sample
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
        return round
      end
    end

    player.lose word
    return nil
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
