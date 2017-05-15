require 'open-uri'
require 'json'
require 'timeout'


class GamesController < ApplicationController
  def game
    @grid = generate_grid(10)
    @attempt = params[:attempt]
    @start_time = params[:start_time]
  end

  def score
    @end_time = Time.now
    @grid = params[:grid].split("")
    @attempt = params[:attempt]
    @start_time = DateTime.parse(params[:start_time])
    @result = run_game(@attempt, @grid, @start_time, @end_time)
    @score = @result[:score]
    @time = @result[:time]
    @translation = @result[:translation]
    @message = @result[:message]
  end

  private

  def generate_grid(grid_size)
  # TODO: generate random grid of letters
  grid = []
  grid_size.times { grid << ("A".."Z").to_a.sample(1) }
  return grid
end

def run_game(attempt, grid, start_time, end_time)
  attempt.upcase
  url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=42e7ec3e-a330-4ca6-b788-a45909b29927&input=#{attempt}"
  url_read = open(url).read
  word_parse = JSON.parse(url_read)
  word_checked =  word_parse["outputs"][0]["output"].upcase
  attempt_array = attempt.chars
  if attempt_array.all? { |letter| attempt_array.count(letter) <= grid.count(letter) }
    if attempt == word_checked
      score = 0
      message = "not an english word"
      translation = nil
    else
      score = attempt_array.size - (end_time - start_time)
      message = "well done"
      translation = word_checked
    end
  else
    score = 0
    message = "not in the grid"
    translation = nil
  end
  return result = {
    time: end_time - start_time,
    translation: translation,
    score: score,
    message: message
    }
  end

end
