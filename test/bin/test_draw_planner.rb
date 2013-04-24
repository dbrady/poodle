require 'minitest/autorun'
require 'digest/md5'

class TestDrawPlanner < MiniTest::Unit::TestCase
  MAGIC_MD5_CHECKSUM="4b8ec4584fce157d810896ddd4a0f701"

  def md5(string)
    digest = Digest::MD5.new
    string.each_line do |line|
      digest << line
    end
    digest.hexdigest
  end

  def execute_draw_planner(date, filename)
    system "bin/draw_planner -d #{@date} -f #{@planner_filename}"
  end

  def execute_delete_planner(filename)
    system "rm -f #{filename}"
  end

  def get_md5_for_planner(filename)
    md5 File.read(filename)
  end

  def setup
    @date = "2012-03-11"
    @planner_filename = "spec_planner_sheet.pdf"
    execute_delete_planner @planner_filename
    execute_draw_planner @date, @planner_filename
  end

  def after
    execute_delete_planner @planner_filename
  end

  def test_draw_planner
    get_md5_for_planner(@planner_filename).must_equal MAGIC_MD5_CHECKSUM
  end

end
