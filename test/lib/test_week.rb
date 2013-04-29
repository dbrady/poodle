require 'minitest/autorun'
require_relative '../test_helper'
require_relative '../../lib/week'

class TestWeek < MiniTest::Unit::TestCase
  def assert_rewinds opts
    from = Date.parse opts[:from]
    to = Date.parse opts[:to]

    week = Week.new :date => from, :starts_on => @start_week_on
    week.beginning_of_week.must_equal to
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
      assert_rewinds :from => mday_to_iso_string(from), :to => mday_to_iso_string(to)
    end
  end

  def self.make_test_methods_for_week opts
    opts[:days].each do |from, to|
      make_test_method_for_week_and_date opts[:starting_on], from, to
    end
  end

  # Okay, to test week rewinding thoroughly, I need about 98
  # assertions. Well, EXACTLY 98 assertions: 7 days to say the work
  # week starts on this day, and 14 days of the month to say "I choose
  # the week containing this date". If we then ask that week when it
  # began, it should rewind to the correct day. I have included here a
  # calendar of April 2013 for handy reference. Below that is a data
  # table that contains the workweek, date chosen, and the expected
  # beginning_of_week for that date in that workweek.
  #
  # I'm not in love with that data structure (it's positionally
  # dependent) but it seems overkill to drag in CSV.
  #
  # Each triad (e.g. "Monday", 17, 15) represents one calendar
  # assertion: "If the workweek starts on Monday, and I pick April
  # 17th, which is a Wednesday, the beginning_of_week should be the
  # 15th". We take this data structure and define a test_ method with
  # a very long yet descriptive name that contains one assertion: that
  # that triad rewound to the correct date.
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
    make_test_methods_for_week :starting_on => start_day, :days => (14..27).to_a.zip(days)
  end

  def assert_week_of_label_is_correct(date_string, expected_label)
    Week.new(:date => Date.parse(date_string)).date_label.must_equal expected_label
  end

  def test_date_label_for_week_returns_correct_date_string_for_week
    assert_week_of_label_is_correct "2012-03-12", "Mar 12 - 18, 2012"
  end

  def test_date_label_for_week_includes_both_months_when_week_spans_months
    assert_week_of_label_is_correct "2012-03-26", "Mar 26 - Apr 1, 2012"
  end

  def test_date_label_for_week_includes_months_but_not_years_when_week_spans_year
    assert_week_of_label_is_correct "2011-12-26", "Dec 26 - Jan 1, 2012"
  end

end
