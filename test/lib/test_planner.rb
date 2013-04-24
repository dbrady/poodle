require 'minitest/autorun'
require_relative '../test_helper'
require 'date'
require 'stringio'

# UGH - monolithic interdependency hell
# require_relative '../../lib/poodle'
require 'prawn'
require_relative '../../lib/date_patches'
require_relative '../../lib/prawn_patches'
require_relative '../../lib/planner'

class TestPlanner < MiniTest::Unit::TestCase
  def setup
    @planner_filename = "spec_planner_sheet.pdf"
    @date = Date.parse '2012-03-11'
  end

  def buffer
    @buffer ||= StringIO.new
  end

  def test_creates_pdf_with_correct_md5_checksum
    Planner.new(@date).generate_into buffer
    buffer.md5.must_equal MAGIC_MD5_CHECKSUM
  end

  # OMG SRP VIO STAHHHP
  # Arbitrary fun: Historically there were no spaces around the hyphen
  # separating the dates, e.g.: "Mar 12-18, 2012". Now there are. When
  # I ported this to Ruby I decided I liked the spaces. Now I
  # don't. Definitely an argument for extracting this to a template so
  # the exact formatting can change without changing the rendering
  # code.
  def test_date_label_for_week_returns_correct_date_string_for_week
    Planner.new(Date.parse("2012-03-12")).date_label_for_week.must_equal "Mar 12 - 18, 2012"
  end

  # OMG SRP VIO STAHHHP
  def test_date_label_for_week_includes_both_months_when_week_spans_months
    Planner.new(Date.parse("2012-03-26")).date_label_for_week.must_equal "Mar 26 - Apr 1, 2012"
  end

  # OMG SRP VIO STAHHHP
  # Arbitrary fun: Historically I made this formatter return
  # "Dec 26, 2011-Jan 1, 2012" but this go around I decided I like the
  # look of just "Dec 26-Jan 1, 2012" better. I may change this back
  # at some point. This is an EXCELLENT candidate for extraction to
  # some kind of templatable date range formatter.
  def test_date_label_for_week_includes_months_but_not_years_when_week_spans_year
    Planner.new(Date.parse("2011-12-26")).date_label_for_week.must_equal "Dec 26 - Jan 1, 2012"
  end
end
