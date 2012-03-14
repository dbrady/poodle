require 'date'
require_relative '../spec_helper'
require 'digest/md5'

describe Planner do
  describe ".generate_pdf" do
    before do
      @planner_filename = "spec_planner_sheet.pdf"
      @date = Date.parse '2012-03-11'
    end

    it "creates a PDF with correct MD5 checksum" do
      buffer = StringIO.new
      Planner.new(@date).generate_into(buffer)
      md5(buffer.string).should == MAGIC_MD5_CHECKSUM
    end
  end

  describe ".date_label_for_week" do
    it "returns correct date string for the week" do
      Planner.new(Date.parse("2012-03-12")).date_label_for_week.should == "Mar 12 - 18, 2012"
    end

    it "includes both month abbrevs when week spans months" do
      Planner.new(Date.parse("2012-03-26")).date_label_for_week.should == "Mar 26 - Apr 1, 2012"
    end

    it "includes months but NOT years when week spans year" do
      Planner.new(Date.parse("2011-12-26")).date_label_for_week.should == "Dec 26 - Jan 1, 2012"
    end
  end
end
