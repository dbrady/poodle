require 'date'

class Date
  # Returns first Monday on or before start_date
  def beginning_of_workweek
    delta = wday - 1
    delta += 7 if delta < 0 # Sundays will advance the date by default
    self - delta
  end
end
