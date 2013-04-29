require 'minitest/autorun'
require_relative '../test_helper'
require 'date'
require 'stringio'
require_relative '../../lib/planner_application'

class TestPlannerApplication < MiniTest::Unit::TestCase
  def setup
    @filename = "spec_planner_sheet.pdf"
    @date_string = '2012-03-11'
    @date = Date.parse @date_string
  end

  def test_create_calls_create_with_class_and_parsed_date_and_filename
    mock = MiniTest::Mock.new
    mock.expect :create, nil, [{:date => @date, :filename => @filename}]
    PlannerApplication.create :class => mock, :date => @date_string, :filename => @filename
    assert mock.verify
  end
end
