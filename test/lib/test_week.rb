require 'minitest/autorun'
require_relative '../test_helper'
require_relative '../../lib/week'

class TestWeek < MiniTest::Unit::TestCase
  def assert_rewinds(from: "2013-04-14", to: "2013-04-08")
    from = Date.parse from
    to = Date.parse to

    week = Week.new date: from, starts_on: @start_week_on
    week.first.must_equal to
  end

  def self.mday_to_iso_string mday
    '2013-04-%02d' % mday
  end
  def mday_to_iso_string mday
    self.class.mday_to_iso_string mday
  end

  def self.mday_to_date mday
    Date.parse mday_to_iso_string mday
  end
  def mday_to_date mday
    self.class.mday_to_date mday
  end


  def self.make_test_method_name week_starts_on, from, to
    sprintf "test_beginning_of_week_when_week_starts_on_a_%s_the_week_of_%s_201304%02d_rewinds_to_201304%02d",
            week_starts_on.downcase,
            mday_to_date(from).strftime("%A").downcase,
            from,
            to
  end

  def self.make_test_method_for_week_and_date week_starting_on, from, to
    define_method(make_test_method_name week_starting_on, from, to) do
      @start_week_on = week_starting_on
      assert_rewinds from: mday_to_iso_string(from), to: mday_to_iso_string(to)
    end
  end

  def self.make_test_methods_for_week(days: [], starting_on: nil)
    days.each do |from, to|
      make_test_method_for_week_and_date starting_on, from, to
    end
  end

  # Okay, to test week rewinding thoroughly, I need about 98
  # assertions. Well, EXACTLY 98 assertions: 7 days to say the work
  # week starts on this day, and 14 days of the month to say "I choose
  # the week containing this date". If we then ask that week when it
  # began, it should rewind to the correct day. I have included here a
  # calendar of April 2013 for handy reference. Below that is a data
  # table that contains the workweek, date chosen, and the expected
  # first day for that date in that workweek.
  #
  # I'm not in love with that data structure (it's positionally
  # dependent) but it seems overkill to drag in CSV.
  #
  # Each triad (e.g. "Monday", 17, 15) represents one calendar
  # assertion: "If the workweek starts on Monday, and I pick April
  # 17th, which is a Wednesday, the first day should be the 15th". We
  # take this data structure and define a test_ method with a very
  # long yet descriptive name that contains one assertion: that that
  # triad rewound to the correct date.
  #
  # Maybe it's my RSpec showing through but I'm so used to factoring
  # code like this into nested contexts that I'm having a hard time
  # seeing a clean way to do this in MiniTest. Then again, I just
  # tried to do this in RSpec and defining that inner loop of from ->
  # to dates is actually still kind of atough.

  #       April 2013
  #  Su Mo Tu We Th Fr Sa
  #  1  2  3  4  5  6
  #  7  8  9 10 11 12 13
  # 14 15 16 17 18 19 20
  # 21 22 23 24 25 26 27
  # 28 29 30

  # If the work |
  # week starts |
  # on this day | And we pick a week on this day in April 2013, when does THAT week begin?
  # ------------+---------------------------------------------------------------------|
  # Weekday     | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 | 27 |
  [
   ["Monday",      8,  15,  15,  15,  15,  15,  15,  15,  22,  22,  22,  22,  22,  22 ],
   ["Tuesday",     9,   9,  16,  16,  16,  16,  16,  16,  16,  23,  23,  23,  23,  23 ],
   ["Wednesday",  10,  10,  10,  17,  17,  17,  17,  17,  17,  17,  24,  24,  24,  24 ],
   ["Thursday",   11,  11,  11,  11,  18,  18,  18,  18,  18,  18,  18,  25,  25,  25 ],
   ["Friday",     12,  12,  12,  12,  12,  19,  19,  19,  19,  19,  19,  19,  26,  26 ],
   ["Saturday",   13,  13,  13,  13,  13,  13,  20,  20,  20,  20,  20,  20,  20,  27 ],
   ["Sunday",     14,  14,  14,  14,  14,  14,  14,  21,  21,  21,  21,  21,  21,  21 ]
  ].each do |start_day, *days|
    make_test_methods_for_week starting_on: start_day, days: (14..27).to_a.zip(days)
  end

  def test_days_returns_mappable
    Week.new(date: Date.parse("2013-04-29")).days.map {|day| day.mday }.must_equal [29, 30, 1, 2, 3, 4, 5]
  end
end
