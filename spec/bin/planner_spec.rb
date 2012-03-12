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
end
