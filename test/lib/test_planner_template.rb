require 'minitest/autorun'
require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../lib/planner_template'))

class TestWeek < MiniTest::Unit::TestCase
  def setup
    @template = PlannerTemplate.new :planner => nil
  end

  def assert_week_of_label_is_correct date_string, expected_label
    week = Week.new(:date => Date.parse(date_string))
    @template.format_week(week).must_equal expected_label
  end

  def test_date_label_for_week_returns_correct_date_string_for_week
    assert_week_of_label_is_correct "2012-03-12", "Mar 12-18, 2012"
  end

  def test_date_label_for_week_includes_both_months_when_week_spans_months
    assert_week_of_label_is_correct "2012-03-26", "Mar 26-Apr 1, 2012"
  end

  def test_date_label_for_week_includes_months_but_not_years_when_week_spans_year
    assert_week_of_label_is_correct "2011-12-26", "Dec 26, 2011-Jan 1, 2012"
  end
end
