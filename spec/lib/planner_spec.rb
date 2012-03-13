require 'date'
require_relative '../spec_helper'
require 'digest/md5'

def md5(string)
  digest = Digest::MD5.new
  string.each_line do |line|
    digest << line
  end
  digest.hexdigest
end

describe Planner do
  describe ".rewind_to_monday" do
    it "rewinds date to previous Monday" do
      Planner.rewind_to_monday(Date.parse('2012-03-15')).should == Date.parse('2012-03-12')
    end

    it "does not rewind if given date is a Monday" do
      Planner.rewind_to_monday(Date.parse('2012-03-12')).should == Date.parse('2012-03-12')
    end
  end

  describe ".draw" do
    before do
      @planner_filename = "spec_planner_sheet.pdf"
      @date = Date.parse '2012-03-11'
    end

    it "writes the PDF with correct MD5 checksum" do
      buffer = StringIO.new
      Planner.should_receive(:open_file).with(@planner_filename, "w").and_yield(buffer)
      Planner.draw @date, @planner_filename
      md5(buffer.string).should == "b2bf5c67cc7ee16ba88c311bcc227856"
    end
  end

  # Returns a label for the week starting on start_date, e.g. "Mar 5 -
  # 11, 2012". If the week spans a month, both month abbreviations are
  # included, e.g. "Mar 26 - Feb 1, 2012". The year is NOT duplicated
  # if it is spanned, mostly because it's very rare and the expansion
  # looks as weird as the unexpanded version. So the correct output
  # for Dec 26, 2011 would be e.g. "Dec 26 - Jan 1, 2012"
  describe ".date_label_for_week" do
    it "returns correct date string for the week" do
      Planner.date_label_for_week(Date.parse("2012-03-12")).should == "Mar 12 - 18, 2012"
    end

    it "includes both month abbrevs when week spans months" do
      Planner.date_label_for_week(Date.parse("2012-03-26")).should == "Mar 26 - Apr 1, 2012"
    end

    it "includes months but NOT years when week spans year" do
      Planner.date_label_for_week(Date.parse("2011-12-26")).should == "Dec 26 - Jan 1, 2012"
    end
  end
end
