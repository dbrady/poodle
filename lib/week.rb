require 'date'

class Week
  DAYS_PER_WEEK = 7
  attr_reader :week_starts_on, :date

  def initialize(opts)
    @date = opts.fetch :date
    @week_starts_on = Date::DAYNAMES.index opts.fetch :starts_on, "Monday"
    raise ArgumentError.new(":starts_on must be a weekday name, E.g. 'Monday', 'Tuesday'") unless week_starts_on
  end

  def beginning_of_week
    @beginning_of_week ||= calculate_beginning_of_week
  end

  def end_of_week
    beginning_of_week + (DAYS_PER_WEEK - 1)
  end

  def calculate_beginning_of_week
    delta = date.wday - week_starts_on
    delta += 7 if delta < 0 # wrap around to previous week
    date - delta
  end

  def date_label_for_week
    label = beginning_of_week.strftime("%b %-d - ")
    label += end_of_week.strftime("%b ") if end_of_week.month != beginning_of_week.month
    label += end_of_week.strftime("%-d, %Y")
  end
end
