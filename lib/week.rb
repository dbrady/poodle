require 'date'

class Week
  # Constant to prevent the magic number 7 appearing in the
  # code. Added to reveal intent more than to protect against the
  # possibility that the value might change. ;-)
  DAYS_PER_WEEK = 7

  # Calendar date chosen to create this week object. Actual date range
  # will span the full week that contains this date.
  attr_reader :date
  # Name (in English) of the weekday this week starts on,
  # e.g. "Monday". Must be one of +Date::DAYNAMES+.
  attr_reader :week_starts_on

  # [:date]
  #     Date object. A calendar date anywhere in the week to be
  #     created
  # [:week_starts_on]
  #     Optional. English string naming the day of the week that the
  #     "work week" starts on. See Date::DAYNAMES for the complete
  #     list. Defaults to "Monday"
  def initialize(date: Date.today, starts_on: "Monday")
    @date, @week_starts_on = date, day_index_for(starts_on)
    raise ArgumentError.new(":starts_on must be a weekday name, E.g. 'Monday', 'Tuesday'") unless week_starts_on
  end

  def day_index_for day_name
    Date::DAYNAMES.index day_name
  end

  # returns Date of the first day of this week. E.g. if you choose the
  # week of Friday 2013-04-19, and the week starts on Monday, this
  # returns a Date object for Monday 2012-04-15.
  def first
    @first ||= calculate_beginning_of_week
  end

  # returns Date of the last day of this week. E.g. if you choose the
  # week of Friday 2013-04-19, and the week starts on Monday, this
  # returns a Date object for Sunday 2012-04-21.
  def last
    first + DAYS_PER_WEEK - 1
  end

  def month_differs?
    first.month != last.month
  end

  def year_differs?
    first.year != last.year
  end

  def days
    (first..last)
  end

  private

  def calculate_beginning_of_week
    date - (date.wday - week_starts_on) % DAYS_PER_WEEK
  end
end
