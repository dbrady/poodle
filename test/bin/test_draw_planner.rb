require 'minitest/autorun'
require_relative '../test_helper.rb'

class TestDrawPlanner < MiniTest::Unit::TestCase
  def setup
    @date = "2012-03-11"
    @planner_filename = "spec_planner_sheet.pdf"
    execute_delete_planner
    execute_draw_planner
  end

  def execute_draw_planner
    system "bin/draw_planner -d #{@date} -f #{@planner_filename}"
  end

  def execute_delete_planner
    system "rm -f #{@planner_filename}"
  end

  def planner_contents
    File.read @planner_filename
  end

  def planner_md5
    planner_contents.md5
  end

  def after
    execute_delete_planner
  end

  def test_draw_planner
    assert_equal MAGIC_MD5_CHECKSUM, planner_md5
  end

end
