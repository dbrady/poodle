require 'date'

class Week
  attr_reader :week_starts_on, :date

  def initialize(opts)
    @date = opts.fetch :date
    @week_starts_on = Date::DAYNAMES.index opts.fetch :starts_on, "Monday"
    raise ArgumentError.new(":starts_on must be a weekday name, E.g. 'Monday', 'Tuesday'") unless week_starts_on
  end

  def beginning_of_week
    delta = date.wday - week_starts_on
    delta += 7 if delta < 0 # wrap around to previous week
    date - delta
  end


end
