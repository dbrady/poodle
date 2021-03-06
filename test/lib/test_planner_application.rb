require 'minitest/autorun'
require_relative '../test_helper'
require 'stringio'
require_relative '../../lib/planner_application'

class TestPlannerApplication < MiniTest::Unit::TestCase
  def setup
    @filename = "spec_planner_sheet.pdf"
    @date_string = '2012-03-11'
    @date = Date.parse @date_string
    @buffer = StringIO.new
  end

  def test_create_calls_create_with_class_and_parsed_date_and_filename
    mock_planner = MiniTest::Mock.new
    mock_class = MiniTest::Mock.new
    mock_class.expect :new, mock_planner, [{date: @date}]
    mock_planner.expect :generate_into, nil, [@buffer]

    PlannerApplication.create klass: mock_class, date: @date_string, buffer: @buffer
    assert mock_class.verify
    assert mock_planner.verify
  end
end
