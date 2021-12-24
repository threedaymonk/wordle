# Experiments with Wordle

Includes a simple implementation of the
[Wordle](https://www.powerlanguage.co.uk/wordle/) game and a robot player
to explore strategies.

This bot has a success rate of about 98% against the included word list. I
suspect that more recondite words like PASHM, ZURFS, and YFERE aren't likely
to turn up in the official game as answers, but it does accept them as
guesses, and they might still be useful to cut down the search space.

## Play

If you just want to play a game to practise:

    ruby play.rb
