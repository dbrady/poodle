require 'minitest/autorun'
require File.expand_path(File.join(__dir__, '../test_helper'))
require 'date'
require 'stringio'
require File.expand_path(File.join(__dir__, '../../lib/planner'))

class TestPlanner < MiniTest::Unit::TestCase
  def setup
    @planner_filename = "spec_planner_sheet.pdf"
    @date = Date.parse '2012-03-11'
  end

  def buffer
    @buffer ||= StringIO.new
  end

  def test_creates_pdf_with_correct_md5_checksum
    Planner.new(date: @date).generate_into buffer
    buffer.md5.must_equal MAGIC_MD5_CHECKSUM
  end
end
