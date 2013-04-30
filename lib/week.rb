require 'date'

class Week
  # Constant to prevent the magic number 7 appearing in the
  # code. Added to reveal intent more than to protect against the
  # possibility that the value might change. ;-)
  DAYS_PER_WEEK = 7
  # Text string to separate beginning and end dates in date range
  #--
  # TODO: SRPV? This belongs in template-drawing code
  DATE_RANGE_SEPARATOR = "-"

  # Calendar date chosen to create this week object. Actual date range
  # will span the full week that contains this date.
  attr_reader :date
  # Name (in English) of the weekday this week starts on,
  # e.g. "Monday". Must be one of +Date::DAYNAMES+.
  attr_reader :week_starts_on

  # [opts] Hash containing construction parameters
  #
  # [:date]
  #     Date object. A calendar date anywhere in the week to be
  #     created
  # [:week_starts_on]
  #     Optional. English string naming the day of the week that the
  #     "work week" starts on. See Date::DAYNAMES for the complete
  #     list. Defaults to "Monday"
  def initialize opts
    @date = opts.fetch :date
    @week_starts_on = Date::DAYNAMES.index opts.fetch :starts_on, "Monday"
    raise ArgumentError.new(":starts_on must be a weekday name, E.g. 'Monday', 'Tuesday'") unless week_starts_on
  end

  # returns Date of the first day of this week. E.g. if you choose the
  # week of Friday 2013-04-19, and the week starts on Monday, this
  # returns a Date object for Monday 2012-04-15.
  def beginning_of_week
    @beginning_of_week ||= calculate_beginning_of_week
  end

  # returns Date of the last day of this week. E.g. if you choose the
  # week of Friday 2013-04-19, and the week starts on Monday, this
  # returns a Date object for Sunday 2012-04-21.
  def end_of_week
    beginning_of_week + DAYS_PER_WEEK - 1
  end

  # Returns a text string representing the date range of the week. If
  # both the year and the month change, both will be present in the
  # range, e.g. "Dec 26, 2011-Jan 1, 2012". Year will be omitted from
  # the first date if the year does not change: "Mar 26-Apr 1,
  # 2012". Month will be omitted from the second date if it does not
  # change: "Mar 12-18, 2012".
  #--
  # TODO: SRPV? This belongs in template-drawing code
  def date_label
    label = ""
    label += beginning_of_week.strftime "%b %-d"
    label += beginning_of_week.strftime ", %Y" if year_differs?
    label += DATE_RANGE_SEPARATOR
    label += end_of_week.strftime "%b " if month_differs?
    label += end_of_week.strftime "%-d, %Y"
  end

  private

  def calculate_beginning_of_week
    date - (date.wday - week_starts_on) % DAYS_PER_WEEK
  end

  def month_differs?
    beginning_of_week.month != end_of_week.month
  end

  def year_differs?
    beginning_of_week.year != end_of_week.year
  end
end
